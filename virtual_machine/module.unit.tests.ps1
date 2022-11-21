Describe "Terraform Demo Tests" {
    BeforeAll -ErrorAction Stop {
        Write-Host "Test Case: Demo" -ForegroundColor Magenta
        Write-Host "Terraform Initializing..."
        terraform init
        Write-Host "Terraform Validating..."
        terraform validate
        Write-Host "Terraform Planning..."
        (terraform plan -out terraform.plan)

        #Parse plan file and pull out provided variables
        $tfPlan = terraform show -json terraform.plan | ConvertFrom-Json
        $variables = $tfPlan.Variables
    }

    Context "Unit" -Tag "Unit" {
        BeforeAll {
            $ResourceGroupAddress = "azurerm_resource_group.resource_group"
            $VirtualNetworkAddress = "azurerm_virtual_network.virtual_network"
            $VmsSubnetAddress = "azurerm_subnet.subnet"
            $VirtualMachineAddress = "azurerm_virtual_machine.virtual_machine"
            $VmNicAddress = "azurerm_network_interface.network_interface"

            $ResourceGroupPlan = ($tfPlan.resource_changes | Where-Object { $_.address -eq $ResourceGroupAddress })[0]
            $VirtualNetworkPlan = ($tfPlan.resource_changes | Where-Object { $_.address -eq $VirtualNetworkAddress })[0]
            $VmsSubnetPlan = ($tfPlan.resource_changes | Where-Object { $_.address -eq $VmsSubnetAddress })[0]
            $VirtualMachinePlan = ($tfPlan.resource_changes | Where-Object { $_.address -eq $VirtualMachineAddress })[0]
            $VmNicPlan = ($tfPlan.resource_changes | Where-Object { $_.address -eq $VmNicAddress })[0]
        }

        #Region Resource Group Tests
        It "Will create resource_group" {
            $ResourceGroupPlan.change.actions[0] | Should -Be "create"
        }
        
        It "Will create resource_group with correct name" {
            $ResourceGroupPlan.change.after.name | Should -Be $Variables.resource_group_name.value
        }
        
        It "Will create resource_group in correct region" {
            $ResourceGroupPlan.change.after.location | Should -Be $Variables.region.value
        }
        #EndRegion Resource Group Tests

        #Region Virtual Network Tests
        It "Will create virtual_network" {
            $VirtualNetworkPlan.change.actions[0] | Should -Be "create"
        }
        
        It "Will create virtual_network in correct region" {
            $VirtualNetworkPlan.change.after.location | Should -Be $Variables.region.value
        }

        It "Will create virtual_network with correct address_space" {
            $VirtualNetworkPlan.change.after.address_space | Should -Be $Variables.vnet.value.address_space
        }

        It "Will create virtual_network in correct resource group" {
            $VirtualNetworkPlan.change.after.resource_group_name | Should -Be $Variables.resource_group_name.value
        }
        #EndRegion Virtual Network Tests

        #Region Vms Subnet Tests
        It "Will create subnet" {
            $VmsSubnetPlan.change.actions[0] | Should -Be "create"
        }

        It "Will assign correct subnet IP Range" {
            $VariableAddressPrefixes = $Variables.subnet.value.vms.address_prefixes
            $VmsSubnetPlan.change.after.address_prefixes | Should -Be $VariableAddressPrefixes
        }
        #EndRegion Vms Subnet Tests

        #Region Virtual Machine Tests
        It "Will create vm" {
            $VirtualMachinePlan.change.actions[0] | Should -Be "create"
        }

        It "Will create vm in correct resource group" {
            $VirtualMachinePlan.change.after.resource_group_name | Should -Be $Variables.resource_group_name.value
        }

        It "Will create vm in correct region" {
            $VirtualMachinePlan.change.after.location | Should -Be $Variables.region.value
        }

        It "Will assign vm correct administrator username" {
            $VirtualMachinePlan.change.after.os_profile.admin_username | Should -Be $Variables.admin_username.value
        }

        It "Will assign vm correct administrator password" {
            $VirtualMachinePlan.change.after.os_profile.admin_password | Should -Be $Variables.admin_password.value
        }

        It "Will provision_vm_agent for vm" {
            $VirtualMachinePlan.change.after.os_profile_windows_config.provision_vm_agent | Should -Be $true
        }
        
        It "Will not enable_automatic_upgrades for vm" {
            $VirtualMachinePlan.change.after.os_profile_windows_config.enable_automatic_upgrades | Should -Be $false
        }
        #EndRegion Virtual Machine Tests

        #Region NIC Tests        
        It "Will create vm_nic" {
            $VmNicPlan.change.actions[0] | Should -Be "create"
        }

        It "Will create vm_nic in correct resource group" {
            $VmNicPlan.change.after.resource_group_name | Should -Be $Variables.resource_group_name.value
        }

        It "Will create vm_nic in correct region" {
            $VmNicPlan.change.after.location | Should -Be $Variables.region.value
        }

        It "Will assign dynamic address allocation" {
            $VmNicPlan.change.after.ip_configuration.private_ip_address_allocation | Should -Be "dynamic"
        }

        It "Will assign an IPv4 address to vm_nic" {
            $VmNicPlan.change.after.ip_configuration.private_ip_address_version | Should -Be "IPv4"
        }
        #EndRegion NIC Tests
    }
}