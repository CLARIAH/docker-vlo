#!/bin/bash

set -e

PRECOMPILED_BUILD_IMAGE="registry.gitlab.com/clarin-eric/build-image:1.0.0"
FRESH_BUILD_IMAGE="docker:1.11.2"
BUILD_IMAGE=${PRECOMPILED_BUILD_IMAGE}

#
# Set default values for parameters
#
MODE="gitlab"
BUILD=0
TEST=0
RELEASE=0
VERBOSE=0
NO_EXPORT=0
FORCE=0

#
# Process script arguments
#
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -b|--build)
        BUILD=1
        ;;
    -f|--force)
        FORCE=1
        ;;
    -h|--help)
        MODE="help"
        ;;
    -l|--local)
        MODE="local"
        ;;
    -n|--no-export)
        NO_EXPORT=1
        ;;
    -r|--release)
        RELEASE=1
        ;;
    -t|--test)
        TEST=1
        ;;
    -v|--verbose)
        VERBOSE=1
        ;;
    *)
        echo "Unkown option: $key"
        MODE="help"
        ;;
esac
shift # past argument or value
done

# Print parameters if running in verbose mode
if [ ${VERBOSE} -eq 1 ]; then
    echo "build=${BUILD}"
    set -x
fi

if [ "${FORCE}" -eq 1 ]; then
    BUILD_IMAGE=${FRESH_BUILD_IMAGE}
fi

source ./copy_data.sh

#
# Execute based on mode argument
#
if [ ${MODE} == "help" ]; then
    echo ""
    echo "build.sh [-lt]"
    echo ""
    echo "  -b, --build      Build docker image"
    echo "  -r, --release    Push docker image to registry"
    echo "  -t, --test       Execute tests"
    echo ""
    echo "  -l, --local      Run workflow locally in a local docker container"
    echo "  -v, --verbose    Run in verbose mode"
    echo "  -f, --force      Force running the build in a fresh environment, requires "
    echo "                   internet access to pull dependencies. Otherwise internet"
    echo "                   access is only needed for the first pull of the precompiled"
    echo "                   build environment image"
    echo "  -n, --no-export  Don't export the build artiface, this is used when running"
    echo "                   the build workflow locally"
    echo ""
    echo "  -h, --help       Show help"
    echo ""
    exit 0
elif [ "${MODE}" == "gitlab" ]; then

    if [ -n "$CI_SERVER" ]; then
        TAG="${CI_BUILD_TAG:-$CI_BUILD_REF}"
        IMAGE_QUALIFIED_NAME="${CI_REGISTRY_IMAGE}:${TAG}"
        IMAGE_FILE_NAME="${CI_REGISTRY_IMAGE##*/}:${TAG}"
    else
        # WARNING: The current working dir must equal the project root dir.
        if [ "${FORCE}" -eq 1 ]; then
            apk --quiet update --update-cache
            apk --quiet add 'git==2.8.3-r0'
        fi
        PROJECT_NAME="$(basename "$(pwd)")"
        TAG="$(git describe --always)"
        IMAGE_QUALIFIED_NAME="$PROJECT_NAME:${TAG:-latest}"
        IMAGE_FILE_NAME="${IMAGE_QUALIFIED_NAME}"
    fi

    IMAGE_FILE_PATH="$(readlink -fn './output/')/$IMAGE_FILE_NAME.tar.gz"
    export IMAGE_QUALIFIED_NAME
    export IMAGE_FILE_PATH

    #Build
    if [ "${BUILD}" -eq 1 ]; then
        echo "**** Building image ****"
        cd -- 'image/'
        if  [ "${NO_EXPORT}" -eq 0 ]; then
            init_data
        fi
        docker build --tag="$IMAGE_QUALIFIED_NAME" .
        if  [ "${NO_EXPORT}" -eq 0 ]; then
            cleanup_data
            #Only export artifact to disk when running in a gitlab CI pipeline
            docker save --output="$IMAGE_FILE_PATH" "$IMAGE_QUALIFIED_NAME"
        fi
    fi

    #Test
    if [ "${TEST}" -eq 1 ]; then
        echo "**** Testing image *******************************"
        echo "*                                                *"
        echo "* Create / override 'run/run-test.sh' to         *"
        echo "* customize.                                     *"
        echo "**************************************************"
        cd -- 'run/'
        apk --quiet update --update-cache
        apk --quiet add 'py-pip==8.1.2-r0'
        pip --quiet --disable-pip-version-check install 'docker-compose==1.8.0'
        docker load --input="$IMAGE_FILE_PATH"
        if [ -f "run-test.sh" ]; then
            sh run-test.sh
        else
            docker-compose up
        fi
        number_of_failed_containers="$(docker-compose ps -q | xargs docker inspect \
            -f '{{ .State.ExitCode }}' | grep -c 0 -v | tr -d ' ')"
        exit "$number_of_failed_containers"
    fi

    #Release
    if [ "${RELEASE}" -eq 1 ]; then
        echo "**** Releasing image ****"
        docker login -u 'gitlab-ci-token' -p "${CI_BUILD_TOKEN}" 'registry.gitlab.com'
        docker load --input="${IMAGE_FILE_PATH}"
        docker push "${IMAGE_QUALIFIED_NAME}"
        docker logout 'registry.gitlab.com'
    fi

elif [ "${MODE}" == "local" ]; then

    SHELL_FLAGS=""
    if [ ${VERBOSE} -eq 1 ]; then
        FLAGS="-x"
    fi

    FLAGS=""
    if [ "${FORCE}" -eq 1 ]; then
        FLAGS="${FLAGS} -f"
    fi

    CMD=""
    if [ ${BUILD} -eq 1 ] && [ ${TEST} -eq 1 ]; then
        CMD="sh ${SHELL_FLAGS} ./build.sh --build --no-export ${FLAGS} && sh ${SHELL_FLAGS} ./build.sh --test ${FLAGS}"
    elif [ ${BUILD} -eq 1 ]; then
        CMD="sh ${SHELL_FLAGS} ./build.sh --build --no-export ${FLAGS}"
    elif [ ${TEST} -eq 1 ]; then
        CMD="sh ${SHELL_FLAGS} build.sh --test ${FLAGS}"
    fi

    # Build process
    cd -- 'image/'
    init_data "local"
    cd -- ..

    docker run \
        --volume='/var/run/docker.sock:/var/run/docker.sock' \
        --rm \
        --volume="$PWD":"$PWD" \
        --workdir="$PWD" \
        -it \
        ${BUILD_IMAGE} \
        sh -c "${CMD}"

    cd -- 'image/'
    cleanup_data
    cd -- ..

else
    exit 1
fi
