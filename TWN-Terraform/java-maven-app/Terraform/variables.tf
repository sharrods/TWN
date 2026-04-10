variable vpc_cidr_block {
  default             = "10.0.0.0/16"
}
variable subnet_cidr_block {
  default             = "10.0.10.0/24"
}
variable avail_zone {
  default             = "us-east-1a"
}
variable env_prefix {
  default             = "dev"
}
variable my_ip {
  default             = "71.205.216.150/32"
}
variable jenkins_ip {
  default             = "137.184.221.131/32"
}
variable instance_type {
  default = "t3.micro"
}
variable region {
  default = "us-east-1"
}