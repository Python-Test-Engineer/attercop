#!/bin/bash
# build-and-test.sh - Local build and test script for multi-Python Docker images

set -e

# Configuration
PYTHON_VERSIONS=("3.9" "3.10" "3.11" "3.12" "3.13")
IMAGE_NAME="myapp"
REGISTRY="localhost:5000"  # Change to your registry

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Function to build image for specific Python version
build_image() {
    local python_version=$1
    local tag="${IMAGE_NAME}:py${python_version}"

    log "Building image for Python ${python_version}..."

    if docker build \
        --build-arg PYTHON_VERSION="${python_version}" \
        -t "${tag}" \
        --progress=plain \
        .; then
        log "✅ Successfully built ${tag}"
        return 0
    else
        error "❌ Failed to build ${tag}"
    fi
}

# Function to test image
test_image() {
    local python_version=$1
    local tag="${IMAGE_NAME}:py${python_version}"

    log "Testing image ${tag}..."

    # Test 1: Python version verification
    log "  Testing Python version..."
    local container_python_version
    container_python_version=$(docker run --rm "${tag}" python -c "import sys; print('.'.join(map(str, sys.version_info[:2])))")

    if [ "${container_python_version}" != "${python_version}" ]; then
        error "  ❌ Python version mismatch! Expected: ${python_version}, Got: ${container_python_version}"
    fi
    log "  ✅ Python version correct: ${container_python_version}"

    # Test 2: Container startup and basic functionality
    log "  Testing container startup..."
    local container_id
    container_id=$(docker run -d "${tag}")

    sleep 3

    if docker ps -q -f id="${container_id}" | grep -q .; then
        log "  ✅ Container started successfully"
        docker logs "${container_id}" 2>/dev/null || true
        docker stop "${container_id}" >/dev/null
        docker rm "${container_id}" >/dev/null
    else
        error "  ❌ Container failed to start"
    fi

    # Test 3: Health check
    log "  Testing health check..."
    if docker run --rm "${tag}" python -c "import sys; print(f'Python {sys.version}'); exit(0)"; then
        log "  ✅ Health check passed"
    else
        error "  ❌ Health check failed"
    fi

    log "✅ All tests passed for ${tag}"
}

# Function to push image
push_image() {
    local python_version=$1
    local local_tag="${IMAGE_NAME}:py${python_version}"
    local remote_tag="${REGISTRY}/${IMAGE_NAME}:py${python_version}"

    if [ "${PUSH_IMAGES}" = "true" ]; then
        log "Pushing ${local_tag} to ${remote_tag}..."
        docker tag "${local_tag}" "${remote_tag}"
        docker push "${remote_tag}"
        log "✅ Pushed ${remote_tag}"
    fi
}

# Function to clean up images
cleanup() {
    if [ "${CLEANUP}" = "true" ]; then
        log "Cleaning up images..."
        for version in "${PYTHON_VERSIONS[@]}"; do
            docker rmi "${IMAGE_NAME}:py${version}" 2>/dev/null || true
        done
        log "✅ Cleanup completed"
    fi
}

# Main execution
main() {
    log "Starting multi-Python Docker build and test process..."

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --push)
                PUSH_IMAGES="true"
                shift
                ;;
            --cleanup)
                CLEANUP="true"
                shift
                ;;
            --python-version)
                PYTHON_VERSIONS=("$2")
                shift 2
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --push              Push images to registry after build"
                echo "  --cleanup           Remove images after testing"
                echo "  --python-version V  Build only specific Python version"
                echo "  --help              Show this help message"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done

    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        error "Docker is not running or not accessible"
    fi

    # Build and test each Python version
    local failed_versions=()

    for version in "${PYTHON_VERSIONS[@]}"; do
        log "Processing Python ${version}..."

        if build_image "${version}"; then
            if test_image "${version}"; then
                push_image "${version}"
                log "✅ Python ${version} - All operations completed successfully"
            else
                warn "Python ${version} - Tests failed"
                failed_versions+=("${version}")
            fi
        else
            warn "Python ${version} - Build failed"
            failed_versions+=("${version}")
        fi

        echo ""
    done

    # Summary
    log "=== BUILD SUMMARY ==="
    log "Total versions processed: ${#PYTHON_VERSIONS[@]}"
    log "Successful: $((${#PYTHON_VERSIONS[@]} - ${#failed_versions[@]}))"
    log "Failed: ${#failed_versions[@]}"

    if [ ${#failed_versions[@]} -gt 0 ]; then
        warn "Failed versions: ${failed_versions[*]}"
        cleanup
        exit 1
    else
        log "🎉 All Python versions built and tested successfully!"
        cleanup
    fi
}

# Trap to ensure cleanup on exit
trap cleanup EXIT

# Run main function
main "$@"
