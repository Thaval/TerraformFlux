variable "github_org" {
  type    = string
  default = "Thaval"  # Replace with your GitHub organization name
}

variable "github_repository" {
  type    = string
  default = "TerraformFlux"  # Replace with your GitHub repository name
}

variable "github_token" {
  type    = string
}

provider "kind" {}

provider "github" {
  owner = var.github_org
  token = var.github_token
}


provider "flux" {
  kubernetes = {
    host                   = kind_cluster.cluster.endpoint
    client_certificate     = kind_cluster.cluster.client_certificate
    client_key             = kind_cluster.cluster.client_key
    cluster_ca_certificate = kind_cluster.cluster.cluster_ca_certificate
  }
  git = {
    url = "ssh://git@github.com/${var.github_org}/${var.github_repository}.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.flux.private_key_pem
    }
  }
}



terraform {
  required_version = ">=1.1.5"

  required_providers {
    flux = {
      source = "fluxcd/flux"
    }
    kind = {
      source  = "tehcyx/kind"
      version = ">=0.0.16"
    }
    github = {
      source  = "integrations/github"
      version = ">=5.18.0"
    }
  }
}


resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "this" {
  title      = "Flux"
  repository = var.github_repository
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}


resource "kind_cluster" "cluster" {
  name = "flux-cluster"
}

resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.this]

  path = "clusters/my-cluster"
}
