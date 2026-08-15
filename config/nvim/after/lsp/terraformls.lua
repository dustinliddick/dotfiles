-- terraform-ls only claims `terraform` and `terraform-vars` by default, so
-- terragrunt files (terragrunt.hcl, *.hcl -> filetype `hcl`) get no server.
-- Adding `hcl` here means the server also attaches to non-Terraform HCL
-- (packer, nomad, .tflint.hcl); harmless, it just parses them as HCL.
return {
  filetypes = { "terraform", "terraform-vars", "hcl" },
  root_markers = { ".terraform", "terragrunt.hcl", ".git" },

  -- nvim-lspconfig's terraformls on_attach calls vim.lsp.codelens.enable(),
  -- which does not exist in nvim 0.11 (the API is refresh/display/run/clear).
  -- That threw ON_ATTACH_ERROR on every terraform buffer and left the server
  -- unusable, so override it with the real call, guarded for future versions
  -- that do add enable().
  on_attach = function(_, bufnr)
    if vim.lsp.codelens.enable then
      vim.lsp.codelens.enable(true, { bufnr = bufnr })
    else
      vim.lsp.codelens.refresh { bufnr = bufnr }
    end
  end,
}
