# DO NOT EDIT. 
# THIS FILE IS MANAGED BY THE BOOTSTRAP PROJECT IN THIS ORGANIZATION.

%{ for key, value in env_vars }
${key}="${value}"
%{ endfor ~}
