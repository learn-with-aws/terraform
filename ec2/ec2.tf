resource "aws_instance" "Jenkins-Server" {
  ami = var.AMI
  instance_type = "t2.medium"
  subnet_id = "subnet-0941be2b68ba67709"
  vpc_security_group_ids = ["sg-0c9b1466e281b8e3f"]
  associate_public_ip_address = true
  monitoring = true
  key_name = "shashi-mumbai"
  tags = {
    Name = "Jenkins-Server"
  }
//  provisioner "file" {
//    source = "jenkins_install.sh"
//    destination = "/tmp/jenkins_install.sh"
//  }
//  provisioner "file" {
//    source = "verify_install_jenkins.sh"
//    destination = "/tmp/verify_install_jenkins.sh"
//  }
//  provisioner "remote-exec" {
//    inline = [
//      "chmod +x /tmp/jenkins_install.sh",
//      "sudo sh /tmp/jenkins_install.sh"
//    ]
//  }

    provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install wget java-1.8.0-openjdk-devel zip unzip epel-release git -y",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import http://pkg.jenkins.io/redhat-stable/jenkins.io.key",
      "sudo yum install jenkins -y",
      "sudo systemctl start jenkins",
      "sudo systemctl enable jenkins",
      "sudo yum install -y ansible"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo curl -O https://bootstrap.pypa.io/get-pip.py",
      "sudo python get-pip.py",
      "sudo yum install awscli"
    ]
  }
  connection {
    host = self.public_ip
    type = "ssh"
    user = var.INSTANCE_USER
    private_key = file(var.PATH_TO_PRIVATE_KEY_FILE)
  }
}

output "instance_ip" {
    value = aws_instance.Jenkins-Server.public_ip
}