#!/bin/bash

set -e

PIP_DOWNLOAD_CMD="pip download --no-deps --disable-pip-version-check"

mkdir -p dist

(
    cd dist

    if [[ -z "${PYARROW_VERSION}" ]]; then
        echo "Set the PYARROW_VERSION environment variable."
        exit 1
    fi

    echo "slimming wheels for pyarrow version ${PYARROW_VERSION}"

    if [ $TARGETPLATFORM == "linux/amd64" ]; then
        $PIP_DOWNLOAD_CMD --python-version 3.10 --platform manylinux2014_x86_64 pyarrow==${PYARROW_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.9 --platform manylinux2014_x86_64 pyarrow==${PYARROW_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.8 --platform manylinux2014_x86_64 pyarrow==${PYARROW_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.7 --platform manylinux2014_x86_64 pyarrow==${PYARROW_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.6 --platform manylinux2014_x86_64 pyarrow==${PYARROW_VERSION}

        $PIP_DOWNLOAD_CMD --python-version 3.10 --platform manylinux2010_x86_64 pyarrow==${PYARROW_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.9 --platform manylinux2010_x86_64 pyarrow==${PYARROW_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.8 --platform manylinux2010_x86_64 pyarrow==${PYARROW_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.7 --platform manylinux2010_x86_64 pyarrow==${PYARROW_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.6 --platform manylinux2010_x86_64 pyarrow==${PYARROW_VERSION}
    elif [ $TARGETPLATFORM == "linux/aarch64" ]; then
        $PIP_DOWNLOAD_CMD --python-version 3.10 --platform manylinux2014_aarch64 pyarrow==${PYARROW_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.9 --platform manylinux2014_aarch64 pyarrow==${PYARROW_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.8 --platform manylinux2014_aarch64 pyarrow==${PYARROW_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.7 --platform manylinux2014_aarch64 pyarrow==${PYARROW_VERSION}
    else
        echo "${TARGETPLATFORM} not currently supported."
    fi 

    for filename in ./*.whl
    do
        zip -d ${filename} \
            \*test\* \
            \*windows\* \
            \*deprecated\* \
            \*cuda\* \
            \*tensorflow\* \
            \*gandiva\* \
            \*orc\* \
            \*json\* \
            \*csv\* \
            \*flight\* \
            \*plasma\* \
            \*hdfs\* \
            \*liba\*.so 
            

        wheel unpack $filename
        sed -i \
            -e 's/from pyarrow._hdfsio import HdfsFile, have_libhdfs//g' \
            -e 's/import pyarrow.hdfs as hdfs//g' \
            -e 's/from pyarrow.hdfs import HadoopFileSystem as _HadoopFileSystem//g' \
            -e 's/"HadoopFileSystem": (_HadoopFileSystem, "HadoopFileSystem"),//g' \
            -e 's/HadoopFileSystem = _HadoopFileSystem//g' \
            pyarrow-${PYARROW_VERSION}/pyarrow/__init__.py
        strip pyarrow-${PYARROW_VERSION}/pyarrow/*.so
        strip pyarrow-${PYARROW_VERSION}/pyarrow/*.so.*
        wheel pack pyarrow-${PYARROW_VERSION}

        rm -r pyarrow-${PYARROW_VERSION}
    done

    pip install \
        --disable-pip-version-check pyarrow==${PYARROW_VERSION} \
        -f . \
        --index-url https://westonsteimel.github.io/pypi-repo \

    python -c "
import pyarrow
import pyarrow.parquet
import pyarrow.feather
import importlib

module = importlib.import_module('pyarrow')
print(module.__version__)
"
)
