from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def root():
    return {"status": "ok"}


@app.get("/health")
def health():
    return {"status": "ok"}


def generate_input():
    pass


def get_probabalities():
    pass


def get_output():
    pass
