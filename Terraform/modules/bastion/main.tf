# resource "aws_instance" "bastion" {
#   ami                         = "ami-0323c3dd2da7fb37d"
#   key_name                    = "poconnor-r7"
#   instance_type               = "t2.micro"
#   vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]
#   associate_public_ip_address = true
#   subnet_id                   = var.public_subnet_ids[0]
#   # lifecycle {
#   #   prevent_destroy = true
#   # }
#   tags = {
#     Name = "${var.env_name}-bastion"
#   }

# }

# resource "aws_security_group" "bastion" {
#   name   = "bastion-security-group"
#   vpc_id = var.vpc_id

#   ingress = [
#     {
#       description      = "Allow access from ssh"
#       self             = false
#       security_groups  = []
#       ipv6_cidr_blocks = []
#       prefix_list_ids  = []
#       protocol         = "tcp"
#       from_port        = 22
#       to_port          = 22
#       cidr_blocks      = []
#     },
#     {
#       description      = "Allow access from Managed Airflow"
#       self             = false
#       security_groups  = [var.airflow_security_group_id]
#       ipv6_cidr_blocks = []
#       prefix_list_ids  = []
#       protocol         = -1
#       from_port        = 0
#       to_port          = 0
#       cidr_blocks      = []
#   }
# ]

#   egress {
#     protocol    = -1
#     from_port   = 0
#     to_port     = 0
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# output "bastion_public_ip" {
#   value = aws_instance.bastion.public_ip
# }
