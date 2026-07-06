@{
    Tenant = @{
        TenantId = '00000000-0000-0000-0000-000000000000'
        Domain   = 'contoso.onmicrosoft.com'
    }

    Authentication = @{
        DefaultMode           = 'Interactive'
        ClientId              = ''
        CertificateThumbprint = ''
    }

    Logging = @{
        LogDirectory     = '.\logs'
        EnableTranscript = $false
    }

    Reporting = @{
        OutputDirectory = '.\out'
        DefaultFormat   = 'Csv'
    }
}
