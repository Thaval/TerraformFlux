# Install Chocolatey
# Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Minikube, Terraform CLI, and Flux CLI via Chocolatey
# choco install minikube terraform flux -y -force

# Check if Minikube is running, start it if not
$minikubeStatus = minikube status --format "{{.MinikubeStatus}}"
if ($minikubeStatus -ne "Running") {
    minikube start
}

$minikubeStatus = minikube status --format "{{.MinikubeStatus}}"
if ($minikubeStatus -ne "Running") {
    Write-Host "Minikube still not running. Is docker running?"
}


# Initialize and apply Terraform configurations
terraform init
$content = Get-Content -Path "$PSScriptRoot\.env";
$keyValuePairs = @{}

# Process each line in the content
$content | ForEach-Object {
    # Split each line into key and value using the '=' separator
    $key, $value = $_ -split '=', 2

    # Trim leading and trailing whitespaces
    $key = $key.Trim()
    $value = $value.Trim()

    # Add key-value pair to the hashtable
    $keyValuePairs[$key] = $value
}

terraform apply -auto-approve -var="github_token=$($keyValuePairs["token"])"
