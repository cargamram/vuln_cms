# Proyecto TFM: *[Laboratorio de Hacking CMS]*

## Resumen

Este Trabajo de Fin de Máster (TFM) se centra en el desarrollo de un laboratorio de seguridad informática con el objetivo de analizar y auditar un sistema web vulnerable en un entorno controlado


## Índice

- [Introducción](#introducción)
- [Objetivos](#objetivos)
- [Metodología](#metodología)
- [Tecnologías Utilizadas](#tecnologías-utilizadas)
- [Instalación y Configuración](#instalación-y-configuración)


## Introducción

En el contexto actual de creciente digitalización y proliferación de amenazas cibernéticas, la seguridad de las aplicaciones web se ha convertido en una prioridad crítica para todo tipo organizaciones. La vulnerabilidad de los sistemas web a ataques y brechas de seguridad subraya la necesidad de herramientas y metodologías efectivas para evaluar y fortalecer la integridad de estas aplicaciones. Este Trabajo de Fin de Máster (TFM) se centra en el desarrollo de un laboratorio de seguridad informática con el objetivo de analizar y auditar un sistema web vulnerable en un entorno controlado.
Para llevar a cabo esta tarea, se emplearán dos herramientas clave, Vagrant y Puppet. Vagrant se utilizará para crear un entorno virtualizado consistente y reproducible, mientras que Puppet se encargará de la automatización y gestión de la configuración del servidor. La elección de Drupal como sistema de gestión de contenidos vulnerable proporciona una plataforma adecuada para identificar y explorar posibles fallos de seguridad, dado que es un CMS ampliamente utilizado y conocido por sus vulnerabilidades en versiones anteriores.
A través de una auditoría de seguridad web, el objetivo del trabajo será evaluar las vulnerabilidades presentes en el sistema y analizar posibles vectores de ataque. Este proceso permitirá una comprensión profunda de las debilidades del sistema y ofrecerá recomendaciones prácticas para mitigar los riesgos asociados.


## Objetivos

Los objetivos específicos de este proyecto son:

1. Implementar un laboratorio de seguridad informática con el objetivo de analizar y auditar un sistema web vulnerable en un entorno controlado.
2. Realizar una auditoria de seguridad web, evaluando las vulnerabilidades presentes en el sistema y analizar posibles vectores de ataque.


## Metodología

Para alcanzar los objetivos planteados, se ha seguido la Guía de Testing de OWASP [OWASP Web Security Testing Guide](https://owasp.org/www-project-web-security-testing-guide/):


## Tecnologías Utilizadas

El proyecto ha sido desarrollado utilizando las siguientes tecnologías:

- **Herramientas:** Vagrant (VirtualBox), Puppet
- **Lenguajes:** Puppet, Shell
- **CMS:** Drupal 7.x


## Instalación y Configuración

### Requisitos Previos

- Para instalar el laboratorio, es necesario tener instalado previamente las herramientas: 
   - VirtualBox: [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)
   - Vagrant: [https://developer.hashicorp.com/vagrant/install?product_intent=vagrant#windows](https://developer.hashicorp.com/vagrant/install?product_intent=vagrant#windows)

### Instalación

1. Clona el repositorio:
   ```bash
   git clone https://github.com/cargamram/vuln_cms.git
   ```

2. Accede con la terminal dentro de la carpeta "vagrant"

3. Escribe el siguiente comando:
   ```bash
   vagrant up
   ```   

4. Una vez instaladas y levantadas las dos máquinas virtuales, es necesario seguir los siguientes pasos:
   
   4.1. Accede a la VM del servidor Puppet (server): 
   ```bash
   vagrant ssh server 
   ```
   
   4.2. Firma el certificado del Puppet Agent (nodo01):
   ```bash
   sudo /opt/puppetlabs/bin/puppetserver ca sign --certname nodo01.domain.local 
   ```

   4.3. Accede a la VM del agente Puppet (nodo01):
   ```bash
   vagrant ssh nodo01
   ```

   4.4. Descarga el catálogo con las herramientas del servidor:
   ```bash
   sudo /opt/puppetlabs/bin/puppet agent --test
   ```

   4.5. Listo! Ya puedes acceder desde tu mismo sistema anfitrión a [localhost:8080](http://localhost:8080/) y verás Drupal instalado con el módulo vulnerable activo.
      - Usuario administrador: admin
      - Contraseña administrador: adminpassword

**Si al apagar la máquina y volverla a levantar, aparece un mensaje de 403 Forbidden, se debe lanzar de nuevo el comando "sudo /opt/puppetlabs/bin/puppet agent --test" desde el nodo01


