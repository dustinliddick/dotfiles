-- terraform-ls only claims `terraform` and `terraform-vars` by default, so
-- terragrunt files (terragrunt.hcl, *.hcl -> filetype `hcl`) get no server.
-- Adding `hcl` here means the server also attaches to non-Terraform HCL
-- (packer, nomad, .tflint.hcl); harmless, it just parses them as HCL.
return {
  filetypes = { "terraform", "terraform-vars", "hcl" },
  root_markers = { ".terraform", "terragrunt.hcl", ".git" },
}
