# DEFAULT
PHONY=build clean

TARGET_VERSION=
CORE_VERSION=
UI_VERSION=

DIST_VERSION=uxmp-${TARGET_VERSION}

DIST_CORE=dist/core
DIST_UI=dist/ui

BUILD_PATH=build/${DIST_VERSION}
BUILD_CORE=${BUILD_PATH}/core
BUILD_UI=${BUILD_PATH}/ui

TARBALL=${DIST_VERSION}.tar.gz

build:clean
	@[ "${CORE_VERSION}" ] || ( echo ">> CORE_VERSION is not set"; exit 1 )
	@[ "${UI_VERSION}" ] || ( echo ">> UI_VERSION is not set"; exit 1 )
	@[ "${TARGET_VERSION}" ] || ( echo ">> TARGET_VERSION is not set"; exit 1 )

	mkdir -p ${BUILD_CORE} ${BUILD_UI}

	git clone git@github.com:uxmp/core.git ${DIST_CORE} && cd ${DIST_CORE} && git checkout ${CORE_VERSION} && composer install --no-dev -a
	sed -i "s/UXMP_VERSION=dev/UXMP_VERSION=${TARGET_VERSION}/" ${DIST_CORE}/.env.dist
	cd ${DIST_CORE} && cp -r .env.dist LICENSE README.md bin src vendor resource ../../${BUILD_CORE}

	git clone git@github.com:uxmp/ui.git ${DIST_UI} && cd ${DIST_UI} && git checkout ${UI_VERSION}
	sed -i "s/VITE_VERSION=dev/VITE_VERSION=${TARGET_VERSION}/" ${DIST_UI}/.env*
	cd ${DIST_UI} && npm install && npm run build
	cp -r ${DIST_UI}/dist/* ${BUILD_UI}

	cd build && tar -czf ${TARBALL} ${DIST_VERSION}

clean:
	rm -rf build/* dist/*
	
force:
