Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$ErrorActionPreference = 'Stop'

$dataFile = Join-Path $PSScriptRoot 'wedding-checklist-data.json'

function New-TaskObject {
    param(
        [hashtable]$Task,
        [int]$Index = 0
    )

    [pscustomobject]@{
        Id          = if ($Task.Id) { [string]$Task.Id } else { "task-$Index" }
        Title       = [string]$Task.Title
        Category    = [string]$Task.Category
        Owner       = [string]$Task.Owner
        Description = [string]$Task.Description
        Notes       = [string]$Task.Notes
        Done        = [bool]$Task.Done
    }
}

function Get-DefaultTasks {
    $seed = @(
        @{ Id = 'budget'; Title = 'Stanovit celkový rozpočet'; Category = 'Plánování'; Owner = 'Společně'; Description = 'Ujasněte si rozpočet na hostinu, oblečení, dekorace, hudbu i rezervy.'; Notes = ''; Done = $false }
        @{ Id = 'date'; Title = 'Vybrat datum svatby'; Category = 'Plánování'; Owner = 'Společně'; Description = 'Zvolte termín, který sedí vám, rodině i dostupnosti dodavatelů.'; Notes = ''; Done = $false }
        @{ Id = 'venue'; Title = 'Zarezervovat místo obřadu a hostiny'; Category = 'Místo'; Owner = 'Společně'; Description = 'Potvrďte lokaci, čas i počet hostů, které místo zvládne.'; Notes = ''; Done = $false }
        @{ Id = 'guests'; Title = 'Připravit seznam hostů'; Category = 'Hosté'; Owner = 'Společně'; Description = 'Sepište hosty a průběžně sledujte potvrzení účasti.'; Notes = ''; Done = $false }
        @{ Id = 'invitations'; Title = 'Objednat nebo vytvořit pozvánky'; Category = 'Hosté'; Owner = 'Nevěsta'; Description = 'Připravte text, design a plán rozeslání pozvánek.'; Notes = ''; Done = $false }
        @{ Id = 'attire-bride'; Title = 'Vybrat svatební šaty'; Category = 'Oblečení'; Owner = 'Nevěsta'; Description = 'Domluvte zkoušky, úpravy a termín vyzvednutí šatů.'; Notes = ''; Done = $false }
        @{ Id = 'attire-groom'; Title = 'Vybrat oblek a doplňky'; Category = 'Oblečení'; Owner = 'Ženich'; Description = 'Vyřešit oblek, košili, boty i sladění s celkovým stylem svatby.'; Notes = ''; Done = $false }
        @{ Id = 'rings'; Title = 'Vybrat a objednat prstýnky'; Category = 'Oblečení'; Owner = 'Společně'; Description = 'Ověřte velikosti, gravírování a termín dodání.'; Notes = ''; Done = $false }
        @{ Id = 'officiant'; Title = 'Domluvit oddávajícího a dokumenty'; Category = 'Formality'; Owner = 'Společně'; Description = 'Zkontrolujte všechny potřebné doklady a termíny na úřadě.'; Notes = ''; Done = $false }
        @{ Id = 'flowers'; Title = 'Objednat květiny a výzdobu'; Category = 'Dekorace'; Owner = 'Nevěsta'; Description = 'Domluvte kytici, korsáže, slavobránu a dekorace stolu.'; Notes = ''; Done = $false }
        @{ Id = 'music'; Title = 'Zajistit hudbu nebo DJ'; Category = 'Program'; Owner = 'Ženich'; Description = 'Potvrďte playlist, ozvučení a harmonogram dne.'; Notes = ''; Done = $false }
        @{ Id = 'photographer'; Title = 'Rezervovat fotografa nebo kameramana'; Category = 'Program'; Owner = 'Společně'; Description = 'Upřesněte styl focení, seznam momentů a časový plán.'; Notes = ''; Done = $false }
        @{ Id = 'cake'; Title = 'Objednat svatební dort'; Category = 'Hostina'; Owner = 'Společně'; Description = 'Vyberte chuť, design, velikost a čas dovezení.'; Notes = ''; Done = $false }
        @{ Id = 'menu'; Title = 'Doladit menu a nápoje'; Category = 'Hostina'; Owner = 'Společně'; Description = 'Vyřešit hlavní chod, vegetariány, dětské porce i pitný režim.'; Notes = ''; Done = $false }
        @{ Id = 'seating'; Title = 'Připravit zasedací pořádek'; Category = 'Hosté'; Owner = 'Společně'; Description = 'Rozmyslete stoly, vztahy mezi hosty a usazení rodiny.'; Notes = ''; Done = $false }
        @{ Id = 'transport'; Title = 'Zajistit dopravu'; Category = 'Logistika'; Owner = 'Ženich'; Description = 'Domluvte auto pro novomanžele, případně dopravu hostů.'; Notes = ''; Done = $false }
        @{ Id = 'accommodation'; Title = 'Vyřešit ubytování pro hosty'; Category = 'Logistika'; Owner = 'Společně'; Description = 'Potvrďte pokoje, počty lidí a instrukce k příjezdu.'; Notes = ''; Done = $false }
        @{ Id = 'timeline'; Title = 'Sepsat harmonogram svatebního dne'; Category = 'Program'; Owner = 'Společně'; Description = 'Udělejte jasný plán od příprav až po večerní zábavu.'; Notes = ''; Done = $false }
        @{ Id = 'vows'; Title = 'Připravit slib nebo řeč'; Category = 'Program'; Owner = 'Nevěsta'; Description = 'Sepište osobní slova, pokud chcete mít vlastní slib.'; Notes = ''; Done = $false }
        @{ Id = 'emergency'; Title = 'Nachystat svatební pohotovostní balíček'; Category = 'Logistika'; Owner = 'Nevěsta'; Description = 'Lepicí náplasti, jehlu, nit, kapesníčky, kosmetiku a další jistoty.'; Notes = ''; Done = $false }
    )

    for ($i = 0; $i -lt $seed.Count; $i++) {
        New-TaskObject -Task $seed[$i] -Index $i
    }
}

function Get-DefaultTaskMap {
    $map = @{}
    foreach ($task in (Get-DefaultTasks)) {
        $map[$task.Id] = $task
    }
    return $map
}

function Normalize-Owner {
    param([string]$Owner)

    switch ($Owner) {
        'Nevesta' { return 'Nevěsta' }
        'Zenich' { return 'Ženich' }
        'Spolecne' { return 'Společně' }
        default { return $Owner }
    }
}

function Normalize-Category {
    param([string]$Category)

    switch ($Category) {
        'Planovani' { return 'Plánování' }
        'Misto' { return 'Místo' }
        'Hoste' { return 'Hosté' }
        'Obleceni' { return 'Oblečení' }
        'Formalnosti' { return 'Formality' }
        default { return $Category }
    }
}

function Load-Tasks {
    if (-not (Test-Path $dataFile)) {
        return @(Get-DefaultTasks)
    }

    try {
        $defaultTaskMap = Get-DefaultTaskMap
        $raw = Get-Content -Path $dataFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $items = @($raw)
        if ($items.Count -eq 0) {
            return @(Get-DefaultTasks)
        }

        $loaded = @()
        for ($i = 0; $i -lt $items.Count; $i++) {
            $item = $items[$i]
            $knownTask = $null
            if ($item.Id -and $defaultTaskMap.ContainsKey([string]$item.Id)) {
                $knownTask = $defaultTaskMap[[string]$item.Id]
            }

            $loaded += New-TaskObject -Task @{
                Id          = $item.Id
                Title       = if ($knownTask) { $knownTask.Title } else { $item.Title }
                Category    = if ($knownTask) { $knownTask.Category } else { Normalize-Category -Category ([string]$item.Category) }
                Owner       = if ($knownTask) { $knownTask.Owner } else { Normalize-Owner -Owner ([string]$item.Owner) }
                Description = if ($knownTask) { $knownTask.Description } else { $item.Description }
                Notes       = $item.Notes
                Done        = $item.Done
            } -Index $i
        }
        return $loaded
    }
    catch {
        [System.Windows.MessageBox]::Show(
            "Nepodařilo se načíst uložená data. Bude použita výchozí šablona.`n`n$($_.Exception.Message)",
            'Svatební checklist',
            'OK',
            'Warning'
        ) | Out-Null
        return @(Get-DefaultTasks)
    }
}

function Save-Tasks {
    param([System.Collections.ObjectModel.ObservableCollection[object]]$Items)

    $json = $Items | ConvertTo-Json -Depth 5
    Set-Content -Path $dataFile -Value $json -Encoding UTF8
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Svatební checklist"
        Height="860"
        Width="1280"
        MinHeight="760"
        MinWidth="1120"
        WindowStartupLocation="CenterScreen">
    <Window.Resources>
        <LinearGradientBrush x:Key="WindowBrush" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#FFFDF4EE" Offset="0" />
            <GradientStop Color="#FFF9F4D9" Offset="0.45" />
            <GradientStop Color="#FFE7F6EE" Offset="1" />
        </LinearGradientBrush>
        <SolidColorBrush x:Key="PanelBrush" Color="#FFFFFEFB" />
        <SolidColorBrush x:Key="PanelAltBrush" Color="#FFFFF6EE" />
        <SolidColorBrush x:Key="AccentBrush" Color="#E06D7C" />
        <SolidColorBrush x:Key="AccentStrongBrush" Color="#C95167" />
        <SolidColorBrush x:Key="AccentSoftBrush" Color="#FFF0D9E0" />
        <SolidColorBrush x:Key="MintBrush" Color="#FFDDF4E9" />
        <SolidColorBrush x:Key="SkyBrush" Color="#FFDCEEFF" />
        <SolidColorBrush x:Key="GoldBrush" Color="#FFF7D98B" />
        <SolidColorBrush x:Key="TextBrush" Color="#4A3340" />
        <SolidColorBrush x:Key="MutedBrush" Color="#8A6D76" />
        <SolidColorBrush x:Key="LineBrush" Color="#F2DADF" />
        <DropShadowEffect x:Key="SoftShadow" BlurRadius="24" ShadowDepth="0" Color="#1F7A4C5B" Opacity="0.35" />
        <Style TargetType="Border" x:Key="CardStyle">
            <Setter Property="CornerRadius" Value="22" />
            <Setter Property="Padding" Value="18" />
            <Setter Property="Background" Value="{StaticResource PanelBrush}" />
            <Setter Property="Margin" Value="0,0,16,0" />
            <Setter Property="BorderBrush" Value="{StaticResource LineBrush}" />
            <Setter Property="BorderThickness" Value="1" />
            <Setter Property="Effect" Value="{StaticResource SoftShadow}" />
        </Style>
        <Style TargetType="TextBlock" x:Key="MutedText">
            <Setter Property="Foreground" Value="{StaticResource MutedBrush}" />
            <Setter Property="FontSize" Value="13" />
        </Style>
        <Style TargetType="Button">
            <Setter Property="Background" Value="{StaticResource AccentBrush}" />
            <Setter Property="Foreground" Value="White" />
            <Setter Property="Padding" Value="16,9" />
            <Setter Property="BorderThickness" Value="0" />
            <Setter Property="FontWeight" Value="SemiBold" />
            <Setter Property="Cursor" Value="Hand" />
            <Setter Property="Margin" Value="0,0,8,0" />
            <Setter Property="FontSize" Value="13" />
        </Style>
        <Style TargetType="ComboBox">
            <Setter Property="Padding" Value="10,6" />
            <Setter Property="Margin" Value="0,0,12,0" />
            <Setter Property="MinWidth" Value="180" />
            <Setter Property="Background" Value="#FFFFFBF8" />
            <Setter Property="BorderBrush" Value="{StaticResource LineBrush}" />
            <Setter Property="BorderThickness" Value="1" />
        </Style>
        <Style TargetType="TextBox">
            <Setter Property="Padding" Value="10,8" />
            <Setter Property="Margin" Value="0,0,12,0" />
            <Setter Property="Background" Value="#FFFFFBF8" />
            <Setter Property="BorderBrush" Value="{StaticResource LineBrush}" />
            <Setter Property="BorderThickness" Value="1" />
        </Style>
    </Window.Resources>

    <Grid Background="{StaticResource WindowBrush}">
        <Canvas IsHitTestVisible="False">
            <Ellipse Width="240" Height="240" Fill="#33F4C6D2" Canvas.Left="-70" Canvas.Top="-50" />
            <Ellipse Width="320" Height="320" Fill="#22A8DCC8" Canvas.Right="-110" Canvas.Top="80" />
            <Ellipse Width="220" Height="220" Fill="#20F5D67B" Canvas.Left="220" Canvas.Bottom="-70" />
            <Canvas Canvas.Left="1020" Canvas.Top="24" Width="110" Height="120">
                <Path Fill="#17E06D7C" Stretch="Fill" Width="72" Height="66" Canvas.Left="18" Canvas.Top="10"
                      Data="M 0 22 C 0 8 14 0 25 0 C 35 0 42 8 45 14 C 48 8 55 0 65 0 C 76 0 90 8 90 22 C 90 41 74 55 45 79 C 16 55 0 41 0 22 Z" />
                <Ellipse Width="8" Height="8" Fill="#55FFFFFF" Canvas.Left="54" Canvas.Top="26" />
                <Path Stroke="#2AD7A3B1" StrokeThickness="2.2" Data="M 58 84 C 55 94 50 102 44 110" />
                <Path Stroke="#2AB3CF96" StrokeThickness="2.2" Data="M 58 84 C 65 92 70 101 73 111" />
            </Canvas>
        </Canvas>

        <Grid Margin="28">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto" />
                <RowDefinition Height="Auto" />
                <RowDefinition Height="Auto" />
                <RowDefinition Height="*" />
                <RowDefinition Height="Auto" />
            </Grid.RowDefinitions>

        <Grid Grid.Row="0" Margin="0,0,0,22">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*" />
                <ColumnDefinition Width="340" />
            </Grid.ColumnDefinitions>
            <Border CornerRadius="28" Padding="28" Margin="0,0,18,0" Background="#CCFFFFFB" BorderBrush="#35FFFFFF" BorderThickness="1" Effect="{StaticResource SoftShadow}">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*" />
                        <ColumnDefinition Width="170" />
                    </Grid.ColumnDefinitions>
                    <StackPanel VerticalAlignment="Center">
                        <Border Background="{StaticResource GoldBrush}" CornerRadius="999" Padding="12,5" HorizontalAlignment="Left">
                            <TextBlock Foreground="{StaticResource TextBrush}" FontWeight="SemiBold" Text="Plánujte s radostí a přehledem" />
                        </Border>
                        <TextBlock Margin="0,18,0,0" FontSize="36" FontWeight="Bold" Foreground="{StaticResource TextBrush}" Text="Svatební přípravy pod kontrolou" TextWrapping="Wrap" />
                        <TextBlock Margin="0,10,0,0" FontSize="15" Foreground="{StaticResource MutedBrush}" Text="Praktický checklist pro nevěstu a ženicha. Odškrtávejte hotové body, doplňujte poznámky a mějte krásně vidět, co je už zařízené." TextWrapping="Wrap" />
                    </StackPanel>
                    <Grid Grid.Column="1" HorizontalAlignment="Right" VerticalAlignment="Center" Width="170" Height="150">
                        <Canvas Width="170" Height="150">
                            <Border Width="108" Height="108" CornerRadius="28" Background="#FFF7E8ED" BorderBrush="#55FFFFFF" BorderThickness="1" Canvas.Left="18" Canvas.Top="10">
                                <Border.Effect>
                                    <DropShadowEffect BlurRadius="18" ShadowDepth="0" Color="#22A55A6E" />
                                </Border.Effect>
                            </Border>
                            <Path Fill="#FFCC5B70" Stretch="Fill" Width="60" Height="56" Canvas.Left="42" Canvas.Top="35"
                                  Data="M 0 18 C 0 7 10 0 20 0 C 28 0 34 6 38 12 C 42 6 48 0 56 0 C 66 0 76 7 76 18 C 76 36 61 49 38 68 C 15 49 0 36 0 18 Z" />
                            <Path Fill="#4CFFFFFF" Stretch="Fill" Width="17" Height="16" Canvas.Left="55" Canvas.Top="43"
                                  Data="M 0 5 C 0 2 2 0 5 0 C 8 0 10 2 10 4 C 10 2 12 0 15 0 C 18 0 20 2 20 5 C 20 8 16 11 10 16 C 4 11 0 8 0 5 Z" />
                            <Border Width="94" Height="94" CornerRadius="26" Background="#FFF2F8EF" BorderBrush="#55FFFFFF" BorderThickness="1" Canvas.Left="72" Canvas.Top="48">
                                <Border.Effect>
                                    <DropShadowEffect BlurRadius="18" ShadowDepth="0" Color="#1F5A7A54" />
                                </Border.Effect>
                            </Border>
                            <Canvas Width="94" Height="94" Canvas.Left="72" Canvas.Top="48">
                                <Ellipse Width="33" Height="33" Stroke="#FFD8A73A" StrokeThickness="5" Canvas.Left="16" Canvas.Top="31" />
                                <Ellipse Width="33" Height="33" Stroke="#FFF0C960" StrokeThickness="5" Canvas.Left="44" Canvas.Top="31" />
                                <Polygon Fill="#FFF4D57A" Points="48,25 51,32 59,33 53,38 55,46 48,42 41,46 43,38 37,33 45,32" />
                                <Ellipse Width="6" Height="6" Fill="#66FFFFFF" Canvas.Left="58" Canvas.Top="36" />
                            </Canvas>
                        </Canvas>
                    </Grid>
                </Grid>
            </Border>
            <Border Grid.Column="1" Background="#CCFFFFFF" CornerRadius="28" Padding="20" BorderBrush="{StaticResource LineBrush}" BorderThickness="1" Effect="{StaticResource SoftShadow}">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto" />
                        <RowDefinition Height="Auto" />
                        <RowDefinition Height="*" />
                    </Grid.RowDefinitions>
                    <WrapPanel>
                        <Border Background="{StaticResource SkyBrush}" CornerRadius="16" Padding="10" Margin="0,0,10,10">
                            <Canvas Width="42" Height="42">
                                <Ellipse Width="12" Height="12" Fill="#FFF6A8B5" Canvas.Left="8" Canvas.Top="5" />
                                <Ellipse Width="12" Height="12" Fill="#FFF3B9C5" Canvas.Left="16" Canvas.Top="9" />
                                <Ellipse Width="12" Height="12" Fill="#FFFFC9D2" Canvas.Left="5" Canvas.Top="15" />
                                <Ellipse Width="12" Height="12" Fill="#FFF7AAB6" Canvas.Left="17" Canvas.Top="18" />
                                <Ellipse Width="10" Height="10" Fill="#FFFFE8A8" Canvas.Left="13" Canvas.Top="13" />
                                <Path Stroke="#FF7CB089" StrokeThickness="2.4" Data="M 18 24 C 20 30 22 34 24 39" />
                                <Path Stroke="#FF7CB089" StrokeThickness="1.8" Data="M 21 28 C 16 28 13 26 10 23" />
                                <Path Stroke="#FF7CB089" StrokeThickness="1.8" Data="M 21 31 C 26 31 29 29 32 26" />
                            </Canvas>
                        </Border>
                        <Border Background="{StaticResource AccentSoftBrush}" CornerRadius="16" Padding="10" Margin="0,0,10,10">
                            <Canvas Width="42" Height="42">
                                <Ellipse Width="16" Height="16" Stroke="#FFD8A73A" StrokeThickness="3.6" Canvas.Left="6" Canvas.Top="16" />
                                <Ellipse Width="16" Height="16" Stroke="#FFF0C960" StrokeThickness="3.6" Canvas.Left="18" Canvas.Top="16" />
                                <Polygon Fill="#FFF6DA84" Points="20,8 22,13 27,14 23,17 24,22 20,19 16,22 17,17 13,14 18,13" />
                            </Canvas>
                        </Border>
                        <Border Background="{StaticResource MintBrush}" CornerRadius="16" Padding="10" Margin="0,0,0,10">
                            <Canvas Width="42" Height="42">
                                <Path Fill="#FFCC5B70" Stretch="Fill" Width="24" Height="22" Canvas.Left="9" Canvas.Top="9"
                                      Data="M 0 8 C 0 3 5 0 9 0 C 12 0 15 2 17 5 C 19 2 22 0 25 0 C 29 0 34 3 34 8 C 34 15 28 20 17 29 C 6 20 0 15 0 8 Z" />
                                <Ellipse Width="4" Height="4" Fill="#66FFFFFF" Canvas.Left="20" Canvas.Top="13" />
                            </Canvas>
                        </Border>
                    </WrapPanel>
                    <TextBlock Grid.Row="1" FontSize="15" FontWeight="SemiBold" Foreground="{StaticResource TextBrush}" Text="Uložení dat" />
                    <TextBlock Grid.Row="2" x:Name="SavePathText" Margin="0,10,0,0" Style="{StaticResource MutedText}" TextWrapping="Wrap" />
                </Grid>
            </Border>
        </Grid>

        <Grid Grid.Row="1" Margin="0,0,0,22">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*" />
                <ColumnDefinition Width="*" />
                <ColumnDefinition Width="*" />
            </Grid.ColumnDefinitions>

            <Border Grid.Column="0" Style="{StaticResource CardStyle}" Background="#FFFEF7F2">
                <StackPanel>
                    <TextBlock Style="{StaticResource MutedText}" Text="Celkový postup" />
                    <TextBlock x:Name="OverallProgressText" Margin="0,8,0,6" FontSize="26" FontWeight="Bold" Foreground="{StaticResource TextBrush}" />
                    <ProgressBar x:Name="OverallProgressBar" Height="12" Maximum="100" Value="0" Foreground="{StaticResource AccentBrush}" Background="#FFF1E0E5" />
                </StackPanel>
            </Border>

            <Border Grid.Column="1" Style="{StaticResource CardStyle}" Background="{StaticResource AccentSoftBrush}">
                <StackPanel>
                    <TextBlock Style="{StaticResource MutedText}" Text="Nevěsta" />
                    <TextBlock x:Name="BrideProgressText" Margin="0,8,0,6" FontSize="26" FontWeight="Bold" Foreground="{StaticResource TextBrush}" />
                    <TextBlock x:Name="BrideSummaryText" Style="{StaticResource MutedText}" TextWrapping="Wrap" />
                </StackPanel>
            </Border>

            <Border Grid.Column="2" Style="{StaticResource CardStyle}" Margin="0" Background="{StaticResource MintBrush}">
                <StackPanel>
                    <TextBlock Style="{StaticResource MutedText}" Text="Ženich" />
                    <TextBlock x:Name="GroomProgressText" Margin="0,8,0,6" FontSize="26" FontWeight="Bold" Foreground="{StaticResource TextBrush}" />
                    <TextBlock x:Name="GroomSummaryText" Style="{StaticResource MutedText}" TextWrapping="Wrap" />
                </StackPanel>
            </Border>
        </Grid>

        <Border Grid.Row="2" Background="#CCFFFFFF" CornerRadius="24" Padding="18" Margin="0,0,0,22" BorderBrush="{StaticResource LineBrush}" BorderThickness="1" Effect="{StaticResource SoftShadow}">
            <StackPanel>
                <TextBlock FontSize="16" FontWeight="SemiBold" Foreground="{StaticResource TextBrush}" Text="Filtry a rychlé akce" />
                <WrapPanel Margin="0,14,0,0">
                    <ComboBox x:Name="CategoryFilter" />
                    <ComboBox x:Name="OwnerFilter" />
                    <ComboBox x:Name="StatusFilter" />
                    <Button x:Name="ResetFiltersButton" Content="Resetovat filtry" />
                    <Button x:Name="MarkDoneButton" Content="Přepnout stav vybraného" />
                    <Button x:Name="DeleteTaskButton" Content="Smazat vybraný úkol" Background="#8A3F35" />
                </WrapPanel>
            </StackPanel>
        </Border>

        <Grid Grid.Row="3">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="1.35*" />
                <ColumnDefinition Width="0.9*" />
            </Grid.ColumnDefinitions>

            <Border Grid.Column="0" Background="#CCFFFFFF" CornerRadius="24" Padding="12" Margin="0,0,18,0" BorderBrush="{StaticResource LineBrush}" BorderThickness="1" Effect="{StaticResource SoftShadow}">
                <DataGrid x:Name="TasksGrid"
                          AutoGenerateColumns="False"
                          HeadersVisibility="Column"
                          CanUserAddRows="False"
                          IsReadOnly="False"
                          GridLinesVisibility="Horizontal"
                          RowHeaderWidth="0"
                          AlternatingRowBackground="#FFFEF5F7"
                          Background="Transparent"
                          BorderThickness="0"
                          SelectionMode="Single"
                          SelectionUnit="FullRow"
                          RowBackground="#FFFFFCFA">
                    <DataGrid.Columns>
                        <DataGridCheckBoxColumn Header="Hotovo" Binding="{Binding Done, Mode=TwoWay, UpdateSourceTrigger=PropertyChanged}" Width="95" />
                        <DataGridTextColumn Header="Úkol" Binding="{Binding Title}" Width="*" IsReadOnly="True" />
                        <DataGridTextColumn Header="Na starosti" Binding="{Binding Owner}" Width="120" IsReadOnly="True" />
                        <DataGridTextColumn Header="Kategorie" Binding="{Binding Category}" Width="130" IsReadOnly="True" />
                    </DataGrid.Columns>
                </DataGrid>
            </Border>

            <StackPanel Grid.Column="1">
                <Border Background="#CCFFFFFF" CornerRadius="24" Padding="18" Margin="0,0,0,18" BorderBrush="{StaticResource LineBrush}" BorderThickness="1" Effect="{StaticResource SoftShadow}">
                    <StackPanel>
                        <TextBlock FontSize="18" FontWeight="SemiBold" Foreground="{StaticResource TextBrush}" Text="Detail úkolu" />
                        <TextBlock x:Name="SelectedTaskTitle" Margin="0,14,0,6" FontSize="24" FontWeight="Bold" Foreground="{StaticResource TextBrush}" Text="Vyberte úkol ze seznamu" TextWrapping="Wrap" />
                        <TextBlock x:Name="SelectedTaskMeta" Style="{StaticResource MutedText}" />
                        <TextBlock x:Name="SelectedTaskDescription" Margin="0,12,0,0" Style="{StaticResource MutedText}" TextWrapping="Wrap" />
                        <TextBlock Margin="0,16,0,8" FontWeight="SemiBold" Foreground="{StaticResource TextBrush}" Text="Poznámky" />
                        <TextBox x:Name="NotesTextBox" Height="120" AcceptsReturn="True" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto" />
                        <WrapPanel Margin="0,14,0,0">
                            <Button x:Name="SaveNotesButton" Content="Uložit poznámku" />
                            <Button x:Name="CompleteSelectedButton" Content="Označit / vrátit zpět" />
                        </WrapPanel>
                    </StackPanel>
                </Border>

                <Border Background="{StaticResource PanelAltBrush}" CornerRadius="24" Padding="18" BorderBrush="{StaticResource LineBrush}" BorderThickness="1" Effect="{StaticResource SoftShadow}">
                    <StackPanel>
                        <TextBlock FontSize="18" FontWeight="SemiBold" Foreground="{StaticResource TextBrush}" Text="Přidat vlastní úkol" />
                        <TextBox x:Name="NewTaskTitle" Margin="0,14,0,12" ToolTip="Název úkolu" />
                        <WrapPanel>
                            <TextBox x:Name="NewTaskCategory" Width="180" ToolTip="Kategorie" />
                            <ComboBox x:Name="NewTaskOwner" Width="160" />
                        </WrapPanel>
                        <TextBox x:Name="NewTaskDescription" Height="90" AcceptsReturn="True" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto" ToolTip="Popis úkolu" />
                        <Button x:Name="AddTaskButton" Content="Přidat úkol" Width="150" Margin="0,14,0,0" />
                    </StackPanel>
                </Border>
            </StackPanel>
        </Grid>

        <TextBlock Grid.Row="4" x:Name="FooterText" Margin="2,18,0,0" Style="{StaticResource MutedText}" />
        </Grid>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$namedControls = @(
    'SavePathText', 'OverallProgressText', 'OverallProgressBar', 'BrideProgressText', 'BrideSummaryText',
    'GroomProgressText', 'GroomSummaryText', 'CategoryFilter', 'OwnerFilter', 'StatusFilter',
    'ResetFiltersButton', 'MarkDoneButton', 'DeleteTaskButton', 'TasksGrid', 'SelectedTaskTitle',
    'SelectedTaskMeta', 'SelectedTaskDescription', 'NotesTextBox', 'SaveNotesButton',
    'CompleteSelectedButton', 'NewTaskTitle', 'NewTaskCategory', 'NewTaskOwner',
    'NewTaskDescription', 'AddTaskButton', 'FooterText'
)

foreach ($controlName in $namedControls) {
    Set-Variable -Name $controlName -Value $window.FindName($controlName) -Scope Script
}

$script:tasks = [System.Collections.ObjectModel.ObservableCollection[object]]::new()
foreach ($task in (Load-Tasks)) {
    $script:tasks.Add($task)
}

if (-not (Test-Path $dataFile)) {
    Save-Tasks -Items $script:tasks
}

$script:selectedTask = $null

function Refresh-CategoryOptions {
    $current = [string]$CategoryFilter.SelectedItem
    $categories = @('Všechny kategorie') + @($script:tasks | ForEach-Object Category | Sort-Object -Unique)
    $CategoryFilter.ItemsSource = $categories
    if ($categories -contains $current) {
        $CategoryFilter.SelectedItem = $current
    }
    else {
        $CategoryFilter.SelectedIndex = 0
    }
}

function Show-SelectedTask {
    if ($null -eq $script:selectedTask) {
        $SelectedTaskTitle.Text = 'Vyberte úkol ze seznamu'
        $SelectedTaskMeta.Text = ''
        $SelectedTaskDescription.Text = 'Tady se zobrazí detail úkolu, jeho popis a místo pro vlastní poznámky.'
        $NotesTextBox.Text = ''
        return
    }

    $SelectedTaskTitle.Text = $script:selectedTask.Title
    $SelectedTaskMeta.Text = "$($script:selectedTask.Category) | $($script:selectedTask.Owner) | " + $(if ($script:selectedTask.Done) { 'Hotovo' } else { 'Rozpracováno' })
    $SelectedTaskDescription.Text = $script:selectedTask.Description
    $NotesTextBox.Text = $script:selectedTask.Notes
}

function Update-Stats {
    $total = $script:tasks.Count
    $completed = @($script:tasks | Where-Object Done).Count
    $percentage = if ($total -gt 0) { [math]::Round(($completed / $total) * 100) } else { 0 }

    $OverallProgressText.Text = "$completed z $total úkolů"
    $OverallProgressBar.Value = $percentage

    $brideTasks = @($script:tasks | Where-Object { $_.Owner -in @('Nevěsta', 'Společně') })
    $brideDone = @($brideTasks | Where-Object Done).Count
    $brideTotal = $brideTasks.Count
    $bridePercent = if ($brideTotal -gt 0) { [math]::Round(($brideDone / $brideTotal) * 100) } else { 0 }
    $BrideProgressText.Text = "$bridePercent %"
    $BrideSummaryText.Text = "$brideDone z $brideTotal úkolů, které se týkají nevěsty nebo obou."

    $groomTasks = @($script:tasks | Where-Object { $_.Owner -in @('Ženich', 'Společně') })
    $groomDone = @($groomTasks | Where-Object Done).Count
    $groomTotal = $groomTasks.Count
    $groomPercent = if ($groomTotal -gt 0) { [math]::Round(($groomDone / $groomTotal) * 100) } else { 0 }
    $GroomProgressText.Text = "$groomPercent %"
    $GroomSummaryText.Text = "$groomDone z $groomTotal úkolů, které se týkají ženicha nebo obou."

    $remaining = $total - $completed
    $FooterText.Text = "Zbývá dokončit $remaining úkolů. Změny se ukládají automaticky do souboru wedding-checklist-data.json."
}

Refresh-CategoryOptions
$OwnerFilter.ItemsSource = @('Všichni') # placeholder
$OwnerFilter.ItemsSource = @('Všichni', 'Nevěsta', 'Ženich', 'Společně')
$StatusFilter.ItemsSource = @('Vše', 'Zbývá', 'Hotovo')
$NewTaskOwner.ItemsSource = @('Nevěsta', 'Ženich', 'Společně')

$OwnerFilter.SelectedIndex = 0
$StatusFilter.SelectedIndex = 0
$NewTaskOwner.SelectedIndex = 2

$SavePathText.Text = $dataFile

$view = [System.Windows.Data.CollectionViewSource]::GetDefaultView($script:tasks)
$view.SortDescriptions.Add((New-Object System.ComponentModel.SortDescription('Category', [System.ComponentModel.ListSortDirection]::Ascending)))
$view.SortDescriptions.Add((New-Object System.ComponentModel.SortDescription('Owner', [System.ComponentModel.ListSortDirection]::Ascending)))
$view.SortDescriptions.Add((New-Object System.ComponentModel.SortDescription('Title', [System.ComponentModel.ListSortDirection]::Ascending)))
$view.Filter = {
    param($item)

    $categoryOk = ($CategoryFilter.SelectedIndex -le 0) -or ($item.Category -eq $CategoryFilter.SelectedItem)
    $ownerOk = ($OwnerFilter.SelectedIndex -le 0) -or ($item.Owner -eq $OwnerFilter.SelectedItem)
    $statusValue = [string]$StatusFilter.SelectedItem
    $statusOk = $true

    if ($statusValue -eq 'Hotovo') {
        $statusOk = [bool]$item.Done
    }
    elseif ($statusValue -eq 'Zbývá') {
        $statusOk = -not [bool]$item.Done
    }

    return ($categoryOk -and $ownerOk -and $statusOk)
}

$TasksGrid.ItemsSource = $view

function Persist-And-Refresh {
    $TasksGrid.Items.Refresh()
    $view.Refresh()
    Update-Stats
    Save-Tasks -Items $script:tasks
    Show-SelectedTask
}

$refreshFilterAction = {
    $view.Refresh()
}

$CategoryFilter.add_SelectionChanged($refreshFilterAction)
$OwnerFilter.add_SelectionChanged($refreshFilterAction)
$StatusFilter.add_SelectionChanged($refreshFilterAction)

$ResetFiltersButton.Add_Click({
    $CategoryFilter.SelectedIndex = 0
    $OwnerFilter.SelectedIndex = 0
    $StatusFilter.SelectedIndex = 0
    $view.Refresh()
})

$TasksGrid.Add_SelectionChanged({
    $script:selectedTask = $TasksGrid.SelectedItem
    Show-SelectedTask
})

$toggleHandler = [System.Windows.RoutedEventHandler]{
    Update-Stats
    Save-Tasks -Items $script:tasks
    Show-SelectedTask
}
$TasksGrid.AddHandler([System.Windows.Controls.Primitives.ToggleButton]::CheckedEvent, $toggleHandler)
$TasksGrid.AddHandler([System.Windows.Controls.Primitives.ToggleButton]::UncheckedEvent, $toggleHandler)

$MarkDoneButton.Add_Click({
    if ($null -eq $TasksGrid.SelectedItem) {
        [System.Windows.MessageBox]::Show('Nejdříve vyberte úkol v seznamu.', 'Svatební checklist', 'OK', 'Information') | Out-Null
        return
    }

    $TasksGrid.SelectedItem.Done = -not $TasksGrid.SelectedItem.Done
    Persist-And-Refresh
})

$CompleteSelectedButton.Add_Click({
    if ($null -eq $script:selectedTask) {
        [System.Windows.MessageBox]::Show('Nejdříve vyberte úkol, který chcete upravit.', 'Svatební checklist', 'OK', 'Information') | Out-Null
        return
    }

    $script:selectedTask.Done = -not $script:selectedTask.Done
    Persist-And-Refresh
})

$SaveNotesButton.Add_Click({
    if ($null -eq $script:selectedTask) {
        [System.Windows.MessageBox]::Show('Nejdříve vyberte úkol ze seznamu.', 'Svatební checklist', 'OK', 'Information') | Out-Null
        return
    }

    $script:selectedTask.Notes = $NotesTextBox.Text
    Persist-And-Refresh
})

$AddTaskButton.Add_Click({
    $title = $NewTaskTitle.Text.Trim()
    $category = $NewTaskCategory.Text.Trim()
    $owner = [string]$NewTaskOwner.SelectedItem
    $description = $NewTaskDescription.Text.Trim()

    if ([string]::IsNullOrWhiteSpace($title)) {
        [System.Windows.MessageBox]::Show('Doplňte prosím název úkolu.', 'Svatební checklist', 'OK', 'Information') | Out-Null
        return
    }

    if ([string]::IsNullOrWhiteSpace($category)) {
        $category = 'Vlastní'
    }

    if ([string]::IsNullOrWhiteSpace($description)) {
        $description = 'Vlastní úkol doplněný do svatebního checklistu.'
    }

    $script:tasks.Add((New-TaskObject -Task @{
        Id          = [guid]::NewGuid().ToString()
        Title       = $title
        Category    = $category
        Owner       = $owner
        Description = $description
        Notes       = ''
        Done        = $false
    }))

    $NewTaskTitle.Text = ''
    $NewTaskCategory.Text = ''
    $NewTaskDescription.Text = ''
    $NewTaskOwner.SelectedIndex = 2

    Refresh-CategoryOptions
    Persist-And-Refresh
})

$DeleteTaskButton.Add_Click({
    if ($null -eq $TasksGrid.SelectedItem) {
        [System.Windows.MessageBox]::Show('Vyberte úkol, který chcete smazat.', 'Svatební checklist', 'OK', 'Information') | Out-Null
        return
    }

    $result = [System.Windows.MessageBox]::Show(
        "Opravdu chcete smazat úkol '$($TasksGrid.SelectedItem.Title)'?",
        'Svatební checklist',
        'YesNo',
        'Question'
    )

    if ($result -ne 'Yes') {
        return
    }

    $itemToRemove = $TasksGrid.SelectedItem
    $script:tasks.Remove($itemToRemove)
    if ($script:selectedTask -eq $itemToRemove) {
        $script:selectedTask = $null
    }
    Refresh-CategoryOptions
    Persist-And-Refresh
})

Update-Stats
Show-SelectedTask

$null = $window.ShowDialog()
