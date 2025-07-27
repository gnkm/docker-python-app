from fastapi import FastAPI
import uvicorn

app = FastAPI(title="Docker Python Sample", version="0.1.0")


@app.get("/")
async def root():
    return {"message": "Hello from Docker Python!"}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)