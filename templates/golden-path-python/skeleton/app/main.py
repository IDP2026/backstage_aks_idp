from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {
        "service": "golden-path-python",
        "status": "running",
        "message": "Hello from the Golden Path service"
    }
