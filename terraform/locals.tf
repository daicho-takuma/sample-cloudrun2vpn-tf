locals {
  env     = "tst"
  project = "vpn-connect"
}

locals {
  aws_network_config = {
    region   = "ap-northeast-1"
    vpc_name = "${local.env}-${local.project}-aws-vpc"
    vpc_cidr = "10.0.0.0/16"
    public_subnet = {
      "${local.env}-${local.project}-aws-public-subnet-1a" = {
        az   = "ap-northeast-1a"
        cidr = "10.0.10.0/24"
      }
    }
    private_subnet = {
      "${local.env}-${local.project}-aws-private-subnet-1a" = {
        az   = "ap-northeast-1a"
        cidr = "10.0.20.0/24"
      }
    }
  }
  gcp_network_config = {
    region   = "asia-northeast1"
    vpc_name = "${local.env}-${local.project}-gcp-vpc"
    general_subnet = {
      "${local.env}-${local.project}-gcp-subnet-ane1" = {
        region = "asia-northeast1"
        cidr   = "10.10.10.0/24"
      }
      "${local.env}-${local.project}-gcp-ilb-backend-subnet-ane1" = {
        region = "asia-northeast1"
        cidr   = "10.10.20.0/24"
      }
    }
    proxy_subnet = {
      "${local.env}-${local.project}-gcp-ilb-proxy-subnet-ane1" = {
        region = "asia-northeast1"
        cidr   = "10.10.30.0/24"
      }
    }
  }
}

locals {
  gcp_vpn_config = {
    asn = 65000
  }
  aws_vpn_config = {
    asn = 65001
  }
}
locals {
  aws_instance_config = {
    ec2_public = {
      "${local.env}-${local.project}-aws-public-vm-01" = {
        az            = "ap-northeast-1a"
        type          = "t2.small"
        private_ip    = "10.0.10.10"
        key_name      = "${local.env}-${local.project}-ec2-user-key"
        sg_name       = "${local.env}-${local.project}-web-sg"
        subnet_name   = "${local.env}-${local.project}-aws-public-subnet-1a"
        protected     = false
        vol_type      = "gp3"
        vol_size      = "10"
        vol_encrypted = true
      }
    }
    ec2_private = {
    }
  }
  gcp_instance_config = {
    "${local.env}-${local.project}-gcp-vm-01" = {
      zone        = "asia-northeast1-a"
      type        = "e2-micro"
      private_ip  = "10.10.10.10"
      subnet_name = "${local.env}-${local.project}-gcp-subnet-ane1"
      sa_name     = "${local.env}-${local.project}-gcp-vm-01-sa"
      protected   = false
      vol_type    = "pd-standard"
      vol_size    = "10"
    }
  }
}
