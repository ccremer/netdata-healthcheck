#!/bin/bash
# original author  : paulfantom
# Cross-arch docker build helper script

REPOSITORY="${REPOSITORY:-netdata-healthcheck}"

fail_on_error() {
    if [ ${1} -ne 0 ]; then
        echo "------------------------ ${2}"
        echo "Exiting with exit code ${1}"
        exit ${1}
    fi
}

if [ ${VERSION+x} ]; then
    VERSION="-${VERSION}"
else
    VERSION=""
fi

docker run --rm --privileged multiarch/qemu-user-static:register --reset

# Build images
for ARCH in armhf amd64 i386 aarch64; do
    image="${REPOSITORY}:${ARCH}${VERSION}"
    echo "Building: ARCH=${ARCH}, tag=${image}"
    docker build --build-arg ARCH="${ARCH}" --tag "${image}" .
    fail_on_error $? "Error building ${image}, check the output above!"
done

# Tag latest
image="${REPOSITORY}:latest"
echo "Tag latest: ${REPOSITORY}:amd64"
docker tag "${REPOSITORY}:amd64" "${image}"
fail_on_error $? "Error tagging ${image}, check the output above!"

# Login
if [ -z ${DOCKER_USERNAME+x} ]; then
    echo "No docker hub username  specified. Exiting without pushing images to registry"
    exit 0
fi
if [ -z ${DOCKER_PASSWORD+x} ]; then
    echo "No docker hub password specified. Exiting without pushing images to registry"
    exit 0
fi
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# Push images
for ARCH in amd64 armhf i386 aarch64; do
    image="${REPOSITORY}:${ARCH}${VERSION}"
    echo "Pushing image: ${image}"
    docker push "${image}"
    fail_on_error $? "Error pushing ${image}, check the output above!"
done

# Push latest
image="${REPOSITORY}:latest"
echo "Pushing image: ${image}"
docker push "${image}"
fail_on_error $? "Error pushing ${image}, check the output above!"

