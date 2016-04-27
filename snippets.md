## Linux Socket Buffer

- Default: 212992 (208 KB)
- Optimized: 67108864 (64 MB)

### Tune kernel socket buffer

Set buffer to optimized:

    sudo sysctl net.core.rmem_max=67108864
    sudo sysctl net.core.wmem_max=67108864
    
    sudo sysctl net.core.rmem_default=67108864
    sudo sysctl net.core.wmem_default=67108864

Reset buffer to default:

    sudo sysctl net.core.rmem_max=212992
    sudo sysctl net.core.wmem_max=212992
    
    sudo sysctl net.core.rmem_default=212992
    sudo sysctl net.core.wmem_default=212992

## Monitor Network Stats

### UDP socket Recv-Q and Send-Q

    watch -n 1 'netstat -planu 2> /dev/null | grep 5050'

### UDP packet drops and receive errors

    watch -n 1 netstat -anus
