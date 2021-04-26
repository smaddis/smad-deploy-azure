output "storagestate_rg_id" {
  value = data.terraform_remote_state.storagestate.outputs.rg_id
}