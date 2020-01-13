#The popular 'dbatools' is a pre-requesite of this project.
#To Install run this:
#Install-Module dbatools

cls


#TODO
#Remove SQLInstance parameter
#Add link to website tools
#Add Execute button
#Identify standard parameters, add helptext?

#Output type: Grid??

#Write output to CSV
    #Two steps:
    #Select columns
    #Then create output

#Add note about not updating anything.

#Retain parameters.

#Save server list.

#Credential choices
    #Windows auth
    #1 credential for all


Add-Type -assembly System.Windows.Forms



##########################################
$AllCommands = Get-Command -Module "dbatools" "Get*"
$AddedControls = New-Object System.Collections.ArrayList


##########################################
$Height = 800


$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='Chase''s SQL Browser'
$main_form.Width = 800
$main_form.Height = $Height
$main_form.AutoSize = $true

$SelectServerLabel = New-Object System.Windows.Forms.Label
$SelectServerLabel.Text = "Enter List of Servers"
$SelectServerLabel.Location  = New-Object System.Drawing.Point(0,20)
$SelectServerLabel.AutoSize = $true
$main_form.Controls.Add($SelectServerLabel)

$Textbox = New-Object System.Windows.Forms.TextBox
$Textbox.Text = "localhost\SQLEXPRESS"
$Textbox.Multiline = $True;
$TextBoxLocation = $Height-50
$Textbox.Location  = New-Object System.Drawing.Point(10,50)
#$Textbox.Size = New-Object System.Drawing.Size(100,100)
$Textbox.Scrollbars = "Vertical" 
$Textbox.Width = 300
$Textbox.Height = 100
#$Textbox.AutoSize = $true
$main_form.Controls.Add($Textbox)

$SelectCommandLabel = New-Object System.Windows.Forms.Label
$SelectCommandLabel.Text = "Select A DbaTools Command"
$SelectCommandLabel.Location  = New-Object System.Drawing.Point(320,20)
$SelectCommandLabel.AutoSize = $true
$main_form.Controls.Add($SelectCommandLabel)

$ComboBox = New-Object System.Windows.Forms.ComboBox
$ComboBox.Width = 300

ForEach ($option in $AllCommands)
{
    $null = $ComboBox.Items.Add($Option.Name);
}
$ComboBox.Location  = New-Object System.Drawing.Point(320,50)
$ComboBox.add_SelectedIndexChanged(
    {
        OnChangeDropDown
    }

)

$ComboBox.SelectedItem = "Get-DbaMaxMemory"





Function OnChangeDropDown()
{

    $SelectedItem = $ComboBox.selectedItem

    Write-Host  $SelectedItem.GetType()

    $CommandDetails =""
    $CommandDetails =Get-Command -Name $SelectedItem

    Write-Host  $CommandDetails.GetType()

    $paramindex = 0

    RemoveOldControls

    $Excluded = 'SqlInstance','SqlCredential','Verbose','Debug','ErrorAction','WarningAction','InformationAction','ErrorVariable','WarningVariable','InformationVariable','OutVariable','OutBuffer','PipelineVariable','EnableException'

    ForEach($p in $CommandDetails.Parameters.Keys)
    {
        if(-not $Excluded.Contains($p))
        {
            AddParameter $paramindex  $p $SelectedItem
            Write-Host $p
            $paramindex++
        }
    }
}

Function RemoveOldControls
{
    ForEach($control in $AddedControls)
    {
        $main_form.Controls.Remove($control)
    }

    $main_form.Refresh

    $AddedControls = New-Object System.Collections.ArrayList
}

Function AddParameter($paramindex, $Param,$SelectedToolName)
{
    $Label = New-Object System.Windows.Forms.Label
    $Label.Text = $Param
    $y = 200+[int](20*$paramindex)
    $Label.Location  = New-Object System.Drawing.Point(20,$y)
    $Label.AutoSize = $true
    #Write-Host "adding $Param.Name" 
    $main_form.Controls.Add($Label)

    $Textbox = New-Object System.Windows.Forms.TextBox

    <#$HashKey = $SelectedToolName + "|" + $Param.Name
    #$DefaultOverride = $DefaultsHash[$HashKey]

    #Write-Host $HashKey
    #Write-Host $DefaultOverride

    if($DefaultOverride -ne $null)
    {
        $Textbox.Text = $DefaultOverride
    }
    else {
        $Textbox.Text = $Param.DefaultValue
    }#>

    $Textbox.Location  = New-Object System.Drawing.Point(220,$y)
    $Textbox.Width = 300
    $Textbox.AutoSize = $true
    #$Param.ControlPointer = $Textbox
    $main_form.Controls.Add($Textbox)

    $AddedControls.Add($Label)
    $AddedControls.Add($Textbox)
    
}

$main_form.Controls.Add($ComboBox)


<#$Textbox = New-Object System.Windows.Forms.TextBox
$Textbox.Text = "Enter Server Name Here"
$TextBoxLocation = $Height-50
$Textbox.Location  = New-Object System.Drawing.Point(150,$TextBoxLocation)
$Textbox.Width = 300
$Textbox.AutoSize = $true
$main_form.Controls.Add($Textbox)


#>

$Button = New-Object System.Windows.Forms.Button
$Button.Location = New-Object System.Drawing.Size(10,$TextBoxLocation)
$Button.Size = New-Object System.Drawing.Size(120,23)
$Button.Text = "Run"
$main_form.Controls.Add($Button)


$Button.Add_Click(
    {
        Write-Host "click"
        $SelectedItem = $ComboBox.selectedItem
        Write-Host $SelectedItem
        $instances = 'DESKTOP-L73CGGT\SQLEXPRESS','localhost\SQLEXPRESS'
        $Results = invoke-expression  "$SelectedItem -SqlInstance `$instances"

        

        #$Results | Export-Csv "D:\test.csv"

        $form = New-Object System.Windows.Forms.Form
        $form.Size = New-Object System.Drawing.Size(1000,800)
        $dataGridView = New-Object System.Windows.Forms.DataGridView
        $dataGridView.Size=New-Object System.Drawing.Size(950,750)

        $columns = New-Object System.Collections.ArrayList
        $rows    = New-Object System.Collections.ArrayList
        DisplayObject $Results 0 $columns  $rows 

        $dataGridView.ColumnCount = $columns.Count
        $dataGridView.ColumnHeadersVisible = $true

        for($i =0;$i -lt $columns.Count;$i++)
        {
            #Write-Host "adding column"
            $dataGridView.Columns[$i].Name = $columns[$i]
        }

        foreach ($row in $rows)
        {    
            $dataGridView.Rows.Add($row)
        }

        $form.Controls.Add($dataGridView)
        $form.ShowDialog()
    })

Function DisplayObject($Parm, $Recursion, $columns , $rows )
{
    #Write-Host "1"
    #Write-Host $columns.GetType()

    if($Parm -is [system.array] -and $Recursion -lt 3)
    {
        #Write-Host "is array"
         for ($i=0; $i -lt $Parm.length; $i++) {
	         #DisplayObject $Results[$i]
            DisplayObject $Parm[$i] ($Recursion+1) $columns $rows
        }

       return
    }

    #TODO: 1 array for columns
    #      multi-array for rows
    #      code to add arrays at end


    $newrow = New-Object 'string[]' 200; 


    ForEach($p in $Parm.PSObject.Properties)
    {
        #Write-Host $columns.GetType()
        $index = $columns.IndexOf($p.Name)
        #Write-Host $index 

        if($index -eq -1)
        {
            #Write-Host "adding $($p.Name)"
            $columns.Add($p.Name)
            #Write-Host $columns
            #Write-Host $columns.GetType()
            $index = $columns.IndexOf($p.Name)
        }

        #Write-Host $index 

        $newrow[$index]=$p.Value

        #Write-Host $p.Name
        #Write-Host $p.Value

    }

    $rows.Add($newrow)


    
}


$main_form.ShowDialog()

#Get-DbaCpuUsage -SQLInstance "DESKTOP-L73CGGT\SQLEXPRESS"