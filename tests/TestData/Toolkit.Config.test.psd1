@{
    Tenant = @{
        TenantId = '11111111-1111-1111-1111-111111111111'
        Domain   = 'fabrikam.onmicrosoft.com'
    }

    Authentication = @{
        DefaultMode = 'Interactive'
    }

    Logging = @{
        EnableTranscript = $false
    }

    Reporting = @{
        DefaultFormat = 'Csv'
    }
}
