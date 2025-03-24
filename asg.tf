resource "aws_launch_template" "app_template" {
  name          = "app-launch-template"
  image_id      = "ami-01e3c4a339a264cc9"  # Change to the correct AMI
  instance_type = "t2.micro"
  key_name      = "asg-key"

  network_interfaces {
    security_groups             = [aws_security_group.ec2_sg.id]
  }

  user_data = base64encode(<<EOF
#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

exec > /var/log/user-data.log 2>&1  # Log output for debugging

echo "===== Updating System ====="
sudo yum update -y
sudo yum install -y gcc-c++ make git

#Install nginx
echo "===== Installing nginx ====="
sudo amazon-linux-extras enable nginx1
sudo yum install -y nginx

echo "===== Installing NVM & Node.js ====="
export NVM_DIR="/home/ec2-user/.nvm"
sudo -u ec2-user bash -c 'curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash'

# Ensure NVM is loaded
echo 'export NVM_DIR="$HOME/.nvm"' | sudo tee -a /home/ec2-user/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' | sudo tee -a /home/ec2-user/.bashrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' | sudo tee -a /home/ec2-user/.bashrc

echo "===== Loading NVM for this session ====="
# Load NVM in this session (for user-data script)
source /home/ec2-user/.nvm/nvm.sh
export NVM_DIR="/home/ec2-user/.nvm"

# Verify if NVM is loaded
echo "===== Verifying if NVM is loaded ====="
which nvm || echo "NVM is NOT loaded"
echo "NVM Directory: $NVM_DIR"

# Install Node.js
sudo -u ec2-user bash -c 'source ~/.bashrc && nvm install 16 && nvm use 16'

# ===== Cloning Node.js App =====
echo "===== Cloning Node.js App ====="
cd /home/ec2-user
sudo -u ec2-user git clone https://jishwinxavier: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@github.com/jishwinxavier/nodejsapp.git
sudo chown -R ec2-user:ec2-user /home/ec2-user/nodejsapp

# Install dependencies
echo "===== Installing Dependencies ====="
cd /home/ec2-user/nodejsapp
sudo -u ec2-user bash -c 'source ~/.bashrc && npm install'

# ===== Installing PM2 & Starting App =====
echo "===== Installing PM2 & Starting App ====="
sudo -u ec2-user bash -c 'source ~/.bashrc && npm install -g pm2'
sudo -u ec2-user bash -c 'source ~/.bashrc && pm2 start server.js --name nodeapp'

# Ensure PM2 restarts on reboot (Prevent exit on failure)
echo "===== Configuring PM2 Startup ====="
sudo -u ec2-user bash -c 'source /home/ec2-user/.nvm/nvm.sh && pm2 startup systemd -u ec2-user --hp /home/ec2-user' || true
sudo -u ec2-user bash -c 'source /home/ec2-user/.nvm/nvm.sh && pm2 save' || true

# ===== Configuring Nginx =====
echo "===== Configuring Nginx ====="
sudo bash -c 'cat > /etc/nginx/conf.d/nodeapp.conf <<EOT
server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOT'

# Restart Nginx
echo "===== Restarting Nginx ====="
sudo nginx -t && sudo systemctl restart nginx
EOF
)
}

resource "aws_autoscaling_group" "app_asg" {
  vpc_zone_identifier = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  desired_capacity    = 1
  min_size           = 1
  max_size           = 2

  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}