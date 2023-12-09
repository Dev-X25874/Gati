## Build

### Install Dependencies and create a virtual env

```
cd Gati/docs
pip install virtualenv
python -m venv .
source bin/activate
pip install sphinx sphinxcontrib-bibtex
```

### Compile

```
cd Gati/docs
source bin/activate
make html -j $(nproc --all)
$BROWSER build/html/index.html
```
