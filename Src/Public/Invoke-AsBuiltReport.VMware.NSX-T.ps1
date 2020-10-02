function Invoke-AsBuiltReport.VMware.NSX-T {
    <#
    .SYNOPSIS
        PowerShell script to document the configuration of VMware NSX-T infrastucture in Word/HTML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware NSX-T infrastucture in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        0.1.0
        Author:         Tim Carman
        Twitter:        @tpcarman
        Github:         tpcarman
        Credits:        Iain Brighton (@iainbrighton) - PScribo module
    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.VMware.NSX-T
    #>

    param (
        [String[]] $Target,
        [PSCredential] $Credential
    )

    # Import Report Configuration
    $Report = $ReportConfig.Report
    $InfoLevel = $ReportConfig.InfoLevel
    $Options = $ReportConfig.Options
    # Used to set values to TitleCase where required
    $TextInfo = (Get-Culture).TextInfo

    #region Script Body
    #---------------------------------------------------------------------------------------------#
    #                                         SCRIPT BODY                                         #
    #---------------------------------------------------------------------------------------------#
    # Connect to NSX-T Manager using supplied credentials
    foreach ($NsxManager in $Target) {
        try {
            Write-PScriboMessage "Connecting to NSX-T Manager '$NsxManager'."
            Connect-NsxtServer -Server $nsxManager -Credential $Credential -ErrorAction Stop
        } catch {
            Write-Error "Unable to connect to NSX-T Manager '$NsxManager'."
            Write-Error $_
            Continue
        }

        # Report index:
        #System
        #    NSX-T Manager
        #    Controllers
        #    Compute Managers
        #    Edge Clusters
        #    Edge Nodes
        #    Transport Nodes
        #    Transport Zones
        #Networking
        #    Logical switches
        #    Gateway/Routers
        #    Segments # TODO
        #    Routing
        #Security
        #    EW firewall
        #    Gateway firewall (NS) # TODO
        #    Extras (URL, IDS, Introspection) # TODO
        #Inventory
        #    Services (NAT, LB, VPN, DHCP, DNS) # TODO
        #    IP address Pools


        Section -Style Heading1 'NSX-T System' {

            try {
                Section -Style Heading2 'NSX-T Manager' {
                    Paragraph 'The following section details the configuration of the NSX-T managers.'
                    BlankLine
                    $NsxtManagers = Get-NSXTManager | Sort-Object Name
                    $NsxtManagerInfo = foreach ($NsxtManager in $NsxtManagers) {
                        [PSCustomObject] @{
                            'Name' = $NsxtManager.Name
                            'ID' = $NsxtManager.Id
                            'IP Address' = $NsxtManager.address
                            'SHA256 Thumbprint' = $NsxtManager.SHA256Thumbprint 
                        }
                    }
                    $TableParams = @{
                        Name = 'NSX-T Managers'
                        ColumnWidths = 25, 25, 25, 25 
                    }
                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    } 
                    $NsxtManagerInfo | Table @TableParams
                }
            } catch {
                Write-Error $_
            }

            try {
                $NsxtControllers = Get-NSXTController | Sort-Object Name
                if ($NsxtControllers) {
                    Section -Style Heading2 'Controllers' {
                        Paragraph 'The following section details the configuration of the NSX-T controllers.'
                        BlankLine
                        $NsxtControllerInfo = foreach ($NsxtController in $NsxtControllers) {
                            [PSCustomObject] @{
                                'Name' = $NsxtController.Name
                                'ID' = $NsxtController.Id
                                'Cluster Status' = $TextInfo.ToTitleCase($NsxtController.ClusterStatus)
                                'Version' = $NsxtController.Version
                            }
                        }
                        $TableParams = @{
                            Name = 'Controllers'
                            ColumnWidths = 25, 25, 25, 25 
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        } 
                        $NsxtControllerInfo | Table @TableParams
                    }
                }
            } catch {
                Write-Error $_
            }

            try {
                $NsxtComputeManagers = Get-NSXTComputeManager | Sort-Object Name
                if ($NsxtComputeManagers) {
                    Section -Style Heading2 'Compute Managers' {
                        Paragraph 'The following section details the configuration of the NSX-T compute managers.'
                        BlankLine
                        $NsxtComputeManagerInfo = foreach ($NsxtComputeManager in $NsxtComputeManagers) {
                            [PSCustomObject] @{
                                'Name' = $NsxtComputeManager.Name
                                'ID' = $NsxtComputeManager.Id
                                'Server' = $NsxtComputeManager.Server
                                'Type' = $NsxtComputeManager.Type
                                'Version' = $NsxtComputeManager.Version
                                'Registration' = $TextInfo.ToTitleCase($NsxtComputeManager.Registration)
                                'Connection' = $TextInfo.ToTitleCase($NsxtComputeManager.Connection)
                            }
                        }
                        $TableParams = @{
                            Name = 'Compute Managers'
                            ColumnWidths = 20, 20, 20, 10, 10, 10, 10
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $NsxtComputeManagerInfo | Table @TableParams
                    }
                }
            } catch {
                Write-Error $_
            }

            try {
                $NsxtEdgeClusters = Get-NSXTEdgeCluster | Sort-Object Name
                if ($NsxtEdgeClusters) {
                    Section -Style Heading2 'Edge Clusters' {
                        Paragraph 'The following section details the configuration of the NSX-T edge clusters.'
                        BlankLine
                        $NsxtEdgeClusterInfo = foreach ($NsxtEdgeCluster in $NsxtEdgeClusters) {
                            Section -Style Heading3 $($NsxtEdgeCluster.Name) {
                                [PSCustomObject]@{
                                    'Name' = $NsxtEdgeCluster.Name
                                    'ID' = $NsxtEdgeCluster.Edge_Cluster_Id
                                    'Resource Type' = $TextInfo.ToTitleCase($NsxtEdgeCluster.Resource_Type)
                                    'Deployment Type' = $TextInfo.ToTitleCase($NsxtEdgeCluster.Deployment_Type).Replace('_',' ')
                                    'Cluster Profile Bindings' = $NsxtEdgeCluster.Cluster_Profile_Bindings
                                    'Member Node Type' = $TextInfo.ToTitleCase($NsxtEdgeCluster.Member_Node_Type).Replace('_',' ')
                                    'Members' = $NsxtEdgeCluster.Members
                                }
                            }
                        }  
                        $TableParams = @{
                            Name = 'Edge Clusters'
                            List = $true
                            ColumnWidths = 50, 50
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $NsxtEdgeClusterInfo | Table @TableParams
                    }
                }
            } catch {
                Write-Error $_
            }


            # Known issue, but no solution:
            #   OperationStopped: Unable to get field 'resource_type', no field of that name found
            #try {
            #    Section -Style Heading2 'NSX-T Edge Nodes' {
            #        Paragraph 'The following section provides a summary of the configured Edge Nodes.'
            #        BlankLine
            #        Get-NSXTFabricNode -Edge | Table -Name 'NSX-T Edge Nodes' -List
            #    }
            #} catch {
            #    Write-Error $_
            #}


            try {
                $NsxtTransportNodes = Get-NSXTTransportNode | Sort-Object Name
                if ($NsxtTransportNodes)
                    Section -Style Heading2 'Transport Nodes' {
                        Paragraph 'The following section details the configuration of the NSX-T transport nodes.'
                        BlankLine
                        $NsxtTransportNodeInfo = foreach ($NsxtTransportNode in $NsxtTransportNodes) {
                            [PSCustomObject] @{
                                'Name' = $NsxtTransportNode.Name
                                'ID' = $NsxtTransportNode.Transport_Node_Id
                                'Maintenance Mode' = $TextInfo.ToTitleCase($NsxtTransportNode.Maintenance_Mode)
                            }
                        }
                        $TableParams = @{
                            Name = 'Transport Nodes'
                            ColumnWidths = 33, 34, 33
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $NsxtTransportNodeInfo | Table @TableParams
                    }
                }
            } catch {
                Write-Error $_
            }

            try {
                Section -Style Heading2 'Transport Zones' {
                    Paragraph 'The following section details the configuration of the NSX-T transport zones.'
                    BlankLine
                    $NsxtTransportZones = Get-NSXTTransportZone | Sort-Object Name
                    $NsxtTransportZoneInfo = foreach ($NsxtTransportZone in $NsxtTransportZones) {
                        Section -Style Heading3 $($NsxtTransportZone.Name) {
                            [PSCustomObject] @{
                                'Name' = $NsxtTransportZone.Name
                                'ID' = $NsxtTransportZone.Id
                                'Host Switch Name' = $NsxtTransportZone.Host_Switch_Name
                                'Host Switch Mode' = $TextInfo.ToTitleCase($NsxtTransportZone.Host_Switch_Mode)
                                'Resource Type' = $NsxtTransportZone.Resource_Type
                                'Transport Type' = $TextInfo.ToTitleCase($NsxtTransportZone.Transport_Type)
                            }
                        }
                    }
                    $TableParams = @{
                        Name = 'Transport Zones'
                        List = $true
                        ColumnWidths = 50, 50
                    }
                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }
                    $NsxtTransportZoneInfo | Table @TableParams
                }
            } catch {
                Write-Error $_
            }

        } # end Section -Style Heading1 'NSX-T System' {


        Section -Style Heading1 'NSX-T Networking' {
            try {
                Section -Style Heading2 'NSX-T Logical Switches' {
                    Paragraph 'The following section provides a summary of the configured Logical Switches.'
                    BlankLine
                    Get-NSXTLogicalSwitch  | Table -Name 'NSX-T Logical Switches' -List
                }
            } catch {
                Write-Error $_
            }

            # get logical routers
            try {
                $LR = Get-NSXTLogicalRouter
                if ($LR) {
                    Section -Style Heading2 'NSX-T Logical Routers' {
                        Paragraph 'The following section provides details about the configured logical routers.'
                        BlankLine

                        foreach ($RouterInfo in $LR)
                        {
                            Section -Style Heading3 "Router: $($RouterInfo.Name)" {
                                Paragraph 'The following section provides more details about the logical router.'
                                BlankLine
                                $RouterInfo | Table -Name 'NSX-T Logical Routers' -List
                                BlankLine

                                ### INTERFACES ###
                                try {
                                    $interfaces = Get-NSXTLogicalRouterPorts -logical_router_id $RouterInfo.Logical_router_id
                                    if($interfaces)
                                    {
                                        Section -Style Heading4 'Interfaces' {
                                            Paragraph 'The following section provides a summary of the configured interfaces.'
                                            BlankLine
                                            $interfaces | Table -Name 'Interfaces' -List
                                        }

                                        BlankLine
                                    }
                                } catch {
                                    Write-Error $_
                                }

                                ### BGP - Only on TIER0s ###
                                if($RouterInfo.router_type -eq "TIER0")
                                {
                                    # Redistribution config
                                    try {
                                        $redist_status = Get-NSXTRedistributionStatus -logical_router_id $RouterInfo.Logical_router_id
                                        if($redist_status)
                                        {
                                            Section -Style Heading4 'BGP Redistribution Status' {
                                                $redist_status | Table -Name 'BGP Redistribution Status' -List
                                            }

                                            BlankLine
                                        }
                                    } catch {
                                        Write-Error $_
                                    }

                                    # Redistribution rules
                                    try {
                                        $redist_rules = Get-NSXTRedistributionRule -logical_router_id $RouterInfo.Logical_router_id
                                        if($redist_rules)
                                        {
                                            Section -Style Heading4 'BGP Redistribution Rules' {
                                                $redist_rules | Table -Name 'BGP Redistribution Rules' -List
                                            }

                                            BlankLine
                                        }
                                    } catch {
                                        Write-Error $_
                                    }

                                    # Neighbhors
                                    try {
                                        $bgp = Get-NSXTBGPNeighbors -logical_router_id $RouterInfo.Logical_router_id
                                        if($bgp)
                                        {
                                            Section -Style Heading4 'BGP Neighbors' {
                                                Paragraph 'The following section provides a summary of the configured BGP neighbors.'
                                                BlankLine
                                                $bgp | Table -Name 'BGP Neighbors' -List
                                            }

                                            BlankLine
                                        }
                                    } catch {
                                        Write-Error $_
                                    }
                                } # end if($RouterInfo.router_type -eq "TIER0")


                                ### Advertisement rules - Only on TIER1s ###
                                if($RouterInfo.router_type -eq "TIER1")
                                {
                                    # Advertisement config
                                    try {
                                        $adver_status = Get-NSXTAdvertisementStatus -logical_router_id $RouterInfo.Logical_router_id
                                        if($adver_status)
                                        {
                                            Section -Style Heading4 'Advertisement Status' {
                                                $adver_status | Table -Name 'Advertisement Status' -List
                                            }

                                            BlankLine
                                        }
                                    } catch {
                                        Write-Error $_
                                    }

                                    # Advertisement rules
                                    try {
                                        $adver_rules = Get-NSXTAdvertisementRule -logical_router_id $RouterInfo.Logical_router_id
                                        if($adver_rules)
                                        {
                                            Section -Style Heading4 'Advertisement Rules' {
                                                $adver_rules | Table -Name 'Advertisement Rules' -List
                                            }

                                            BlankLine
                                        }
                                    } catch {
                                        Write-Error $_
                                    }
                                } # end if($RouterInfo.router_type -eq "TIER1")

                                ### Static Routes ###
                                try {
                                    $static = Get-NSXTStaticRoute -logical_router_id $RouterInfo.Logical_router_id
                                    if($static)
                                    {
                                        Section -Style Heading4 'Static Routes' {
                                            Paragraph 'The following section provides a summary of the configured static routes.'
                                            BlankLine
                                            $static | Table -Name 'Static Routes' -List
                                        }

                                        BlankLine
                                    }
                                } catch {
                                    Write-Error $_
                                }

                                ### NAT ####
                                try {
                                    $nat = Get-NSXTNATRule -logical_router_id $RouterInfo.Logical_router_id
                                    if($nat)
                                    {
                                        Section -Style Heading4 'NAT Rules' {
                                            Paragraph 'The following section provides a summary of the configured NAT rules.'
                                            BlankLine
                                            $nat | Table -Name 'NAT Rules' -List
                                        }

                                        BlankLine
                                    }
                                } catch {
                                    Write-Error $_
                                }


                            } # end Section -Style Heading3 $LR.Name {
                        }
                    }
                }
            } catch {
                Write-Error $_
            }

            try {
                Section -Style Heading2 'NSX-T Network Routes' {
                    Paragraph 'The following section provides a summary of the configured Network Routes.'
                    BlankLine
                    Get-NSXTNetworkRoutes  | Table -Name 'NSX-T Network Routes' -List
                }
            } catch {
                Write-Error $_
            }

        } # end Section -Style Heading1 'NSX-T Networking' {

        Section -Style Heading1 'NSX-T Security' {

            try {
                Section -Style Heading2 'NSX-T Distributed Firewall Rules' {
                    Paragraph 'The following section provides a summary of the configured Compute Managers.'
                    BlankLine
                    Get-NSXTFirewallRule  | Table -Name 'NSX-T Distributed Firewall Rules' -List
                }
            } catch {
                Write-Error $_
            }


        } # end Section -Style Heading1 'NSX-T Security' {

        Section -Style Heading1 'NSX-T Inventory' {

            try {
                $IPAMBlock = Get-NSXTIPAMIPBlock
                if ($IPAMBlock) {
                    Section -Style Heading2 'NSX-T IPAM Block' {
                        Paragraph 'The following section provides a summary of the configured Compute Managers.'
                        BlankLine
                        $IPAMBlock | Table -Name 'NSX-T IPAM Block' -List
                    }
                }
            } catch {
                Write-Error $_
            }

            try {
                Section -Style Heading2 'NSX-T IP Pool' {
                    Paragraph 'The following section provides a summary of the configured Compute Managers.'
                    BlankLine
                    Get-NSXTIPPool  | Table -Name 'NSX-T IP Pool' -List
                }
            } catch {
                Write-Error $_
            }


        } # end Section -Style Heading1 'NSX-T Inventory' {


        Disconnect-NsxtServer -Confirm:$false
    } # End of Foreach $NsxManager
    #endregion Script Body
} # End Invoke-AsBuiltReport.VMware.NSX-T function