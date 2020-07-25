#!/bin/bash

set -e

PIP_DOWNLOAD_CMD="pip download --no-deps --disable-pip-version-check"

mkdir -p dist

(
    cd dist

    if [[ -z "${PYARROW_VERSION}" ]]; then
        PYARROW_VERSION=$(pip search pyarrow | pcregrep -o1 -e "^pyarrow \((.*)\).*$")
    fi

    echo "slimming wheels for pyarrow version ${PYARROW_VERSION}"
    
    $PIP_DOWNLOAD_CMD --python-version 3.8 --platform manylinux2014_x86_64 pyarrow==${PYARROW_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.7 --platform manylinux2014_x86_64 pyarrow==${PYARROW_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.6 --platform manylinux2014_x86_64 pyarrow==${PYARROW_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.5 --platform manylinux2014_x86_64 pyarrow==${PYARROW_VERSION} 
    $PIP_DOWNLOAD_CMD --python-version 3.8 --platform manylinux2010_x86_64 pyarrow==${PYARROW_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.7 --platform manylinux2010_x86_64 pyarrow==${PYARROW_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.6 --platform manylinux2010_x86_64 pyarrow==${PYARROW_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.5 --platform manylinux2010_x86_64 pyarrow==${PYARROW_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.8 --platform manylinux1_x86_64 pyarrow==${PYARROW_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.7 --platform manylinux1_x86_64 pyarrow==${PYARROW_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.6 --platform manylinux1_x86_64 pyarrow==${PYARROW_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.5 --platform manylinux1_x86_64 pyarrow==${PYARROW_VERSION}

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
            \*plasma-store-server \
            \*plasma_store \
            \*hdfs\* \
            \*liba\*.so

        wheel unpack $filename
        sed -i -e 's/import pyarrow.hdfs as hdfs//g' -e 's/from pyarrow.hdfs import HadoopFileSystem//g' pyarrow-${PYARROW_VERSION}/pyarrow/__init__.py
        strip pyarrow-${PYARROW_VERSION}/pyarrow/*.so
        strip pyarrow-${PYARROW_VERSION}/pyarrow/*.so.*
        wheel pack pyarrow-${PYARROW_VERSION}

        rm -r pyarrow-${PYARROW_VERSION}
    done

    pip uninstall -y --disable-pip-version-check pyarrow
    pip install --disable-pip-version-check pyarrow -f .

    python -c "
import pyarrow
import pyarrow.parquet
import pyarrow.feather
import importlib

module = importlib.import_module('pyarrow')
print(module.__version__)
"
)
