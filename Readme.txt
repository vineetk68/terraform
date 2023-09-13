Steps:
Replace <PATH-TO-YOUR-GCP-JSON-KEY-FILE> with the path to your Google Cloud service account JSON key file. (already done account.json)
Replace <YOUR-GCP-PROJECT-ID> with your actual Google Cloud Project ID. (already done emerald-lattice-136623)
Replace <YOUR-DOMAIN-NAME> with your actual Domain. (already done promo.app15.in)
run Terraform commands (init, plan, and apply).
Run the plan command with the -out option: terraform plan -out=my-plan
To apply this saved plan run the command: terraform apply "my-plan"