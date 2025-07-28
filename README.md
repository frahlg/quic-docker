# MQTT over QUIC with pynng-mqtt

This project builds a working Docker container for [pynng-mqtt](https://github.com/wanghaEMQ/pynng-mqtt), which enables MQTT over the QUIC protocol.

## What is this?

pynng-mqtt is a Python extension for NanoSDK that makes it possible to send MQTT messages over QUIC instead of traditional TCP. QUIC provides better performance, lower latency, and better handling of network losses.

## Features

- ✅ MQTT over QUIC
- ✅ MQTT over TCP (for comparison)
- ✅ TLS support for secure communication
- ✅ Async/await support
- ✅ Publisher/Subscriber patterns

## Quick Start

### 1. Build Docker container
```bash
docker build -t pynng-mqtt-working .
```

### 2. Run interactive shell
```bash
docker run --rm -it pynng-mqtt-working bash
```

### 3. Test the library
```bash
# Inside the container
cd /app
python3 -c "import pynng; print('✅ pynng-mqtt works!')"
```

## Examples

### MQTT over QUIC

**Publisher:**
```bash
# Inside the container
python3 examples/mqtt_quic_pub.py topic_name 1 "Hello QUIC!"
```

**Subscriber:**
```bash
# Inside the container  
python3 examples/mqtt_quic_sub.py topic_name 1
```

### MQTT over TCP (for comparison)

**Publisher:**
```bash
python3 examples/mqtt_tcp_pub.py topic_name 1 "Hello TCP!"
```

**Subscriber:**
```bash
python3 examples/mqtt_tcp_sub.py topic_name 1
```

### TLS configuration
```bash
python3 examples/mqtt_quic_tls.py topic_name 1
```

## Python API Example

```python
import pynng
import asyncio

async def mqtt_quic_example():
    # MQTT over QUIC
    address = "mqtt-quic://127.0.0.1:14567"
    
    with pynng.Mqtt_quic(address) as mqtt:
        # Create connect message
        connmsg = pynng.Mqttmsg()
        connmsg.set_packet_type(1)  # Connect
        
        # Send message
        await mqtt.asend(connmsg)
        
        print("MQTT over QUIC works!")

# Run
asyncio.run(mqtt_quic_example())
```

## Technical Details

### Solution to build problems

The original pynng-mqtt had compatibility issues:

1. **Old mbedtls version**: Original commit `04a049bda1ce...` doesn't work with modern CMake
2. **MsQuic library path**: `libmsquic.so.2` was not found by the system

### Fixes implemented:

1. **Updated mbedtls**: Changed to `mbedtls-3.6.4` which is compatible with modern CMake
2. **Library cache**: Added `ldconfig` after MsQuic installation
3. **System dependencies**: Installed necessary mbedtls development packages

## File Structure

```
quic-docker/
├── Dockerfile          # Main configuration
└── README.md           # This file
```

## Requirements

- Docker
- ~2GB disk space for build
- Python 3.6+ (included in container)

## Troubleshooting

### Import errors
If you get `ImportError: libmsquic.so.2: cannot open shared object file`:
```bash
# Inside the container, check that libraries are installed
ldconfig -p | grep msquic
```

### Build errors
If the Docker build fails:
```bash
# Clear Docker cache
docker system prune -a

# Build again
docker build -t pynng-mqtt-working .
```

## Contributing

This is a container wrapper for the original [pynng-mqtt project](https://github.com/wanghaEMQ/pynng-mqtt). 

For feature requests or bugs related to the actual MQTT-over-QUIC functionality, see the original repository.

## License

Same as the original pynng-mqtt: MIT License 