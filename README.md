# NookBook

This is the training project for the "Mnesia: Concept to Reality" course for ElixirConf 2020. The branches and commits to the "main" branch correspond to details in the provided Google Document. The outline for those steps are:

### Build the Nook Book Application

- Step 1: Project Setup
- Step 2: Mnesia Schema Setup
- Step 3: Table Setup
- Step 4: Create a Repo for Easier Mnesia Access
- Step 5: Expand the GenericCache Module
- Step 6: A Simple API Client
- Step 7: Create a Simple Cache
- Step 8: Create a LiveView for the Application
- Step 9: Create a Controller for Our Images
- Step 10: Update Our Router
- Step 11: Build Out the HTML
- Step 12: Setup Local Multi-Node Mnesia

### Deploy Nook Book to AWS

- Step 13: Setup Release
- Step 14: Setup Circle
- Step 15: Setup AWS
- Step 16: Setup Terraform
- Step 17: Implement Security Group
- Step 18: Update Release Files
- Step 19: Finish Infrastructure Setup
- Step 20: Use Terraform Output for Hosts
- Step 21: Setup Libcluster
- Step 22: Use Terraform Output for SSH Config
- Step 23: Build and Download Release
- Step 24: Upload and Run the Release



## Guide specific values that need to be changed

- "name" variable near the top of "config/releases.exs"
- hosts: array in the libcluster config in "config/releases.exs"
- "name" default value at the top of "infrastructure/main.tf"
- "sshkey" default value at the top of "infrastructure/output.tf"