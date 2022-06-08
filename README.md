# Taxila Docker

To install Taxila on ubuntu system, we need to have docker container. The reason is because, Taxila uses library PETSc 3.17 (Portable, Extensible Toolkit for Scientific Computation), a suite of data structures and routines for the scalable (parallel) solution of scientific applications modeled by partial differential equations. 

### 1°

- Para iniciar o docker vá onde está o arquivo Dockerfile e rode:
-- docker build .

### 2°

- Pegue o ID do docker (docker images) e rode:
-- docker run -d -P --name taxila2 docker_id

### 3°

- Printe a tela que o docker usa:
-- echo `sudo docker port test_sshd_container`

### 3°

- Por fim pegue o ip do docker:
-- echo `docker inspect taxila2 | grep 'IPAddress'`




