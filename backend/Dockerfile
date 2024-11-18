FROM python:3.11-alpine

RUN pip3 install flask

COPY python /opt/backend

ENTRYPOINT ["python"]
CMD ["/opt/backend/simple-backend.py"]