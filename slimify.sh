#!/bin/bash

set -e

PIP_DOWNLOAD_CMD="pip download --no-deps --disable-pip-version-check"

mkdir -p dist

(
    cd dist
    pip_pyarrow_package="pyarrow"

    if [[ -n "${PYARROW_VERSION}" ]]; then
        pip_pyarrow_package="pyarrow==${PYARROW_VERSION}"
    fi

    
    $PIP_DOWNLOAD_CMD --python-version 3.8 --platform manylinux2014_x86_64 $pip_pyarrow_package
    $PIP_DOWNLOAD_CMD --python-version 3.7 --platform manylinux2014_x86_64 $pip_pyarrow_package
    $PIP_DOWNLOAD_CMD --python-version 3.6 --platform manylinux2014_x86_64 $pip_pyarrow_package
    $PIP_DOWNLOAD_CMD --python-version 3.8 --platform manylinux2010_x86_64 $pip_pyarrow_package
    $PIP_DOWNLOAD_CMD --python-version 3.7 --platform manylinux2010_x86_64 $pip_pyarrow_package
    $PIP_DOWNLOAD_CMD --python-version 3.6 --platform manylinux2010_x86_64 $pip_pyarrow_package
    $PIP_DOWNLOAD_CMD --python-version 3.8 --platform manylinux1_x86_64 $pip_pyarrow_package
    $PIP_DOWNLOAD_CMD --python-version 3.7 --platform manylinux1_x86_64 $pip_pyarrow_package
    $PIP_DOWNLOAD_CMD --python-version 3.6 --platform manylinux1_x86_64 $pip_pyarrow_package

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

        mkdir -p pyarrow
        unzip -c "${filename}" pyarrow/__init__.py | sed -e 's/import pyarrow.hdfs as hdfs//g' -e 's/from pyarrow.hdfs import HadoopFileSystem//g' | > ./pyarrow/__init__.py

        zip -u "${filename}" ./pyarrow/__init__.py

        rm -r pyarrow
    done

    pip uninstall -y --disable-pip-version-check pyarrow
    pip install --disable-pip-version-check pyarrow -f .

    python -c "
import pyarrow
import pyarrow.parquet
import pyarrow.feather
"
)
