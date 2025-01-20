# previewsites.dev

**previewsites.dev** is a lightweight and efficient site preview solution built using **Nginx + Lua** and designed to provide a seamless way to preview websites on a temporary subdomain. This tool is perfect for hosting providers, developers, or anyone who needs to preview sites during migrations or development without modifying the live domain's DNS records.

---

## 🚀 **Features**

- **Domain & IP Preview**:
  - Enter the domain name and target server IP to create a live preview of the site on a temporary subdomain.
  - Allows testing of sites hosted on new servers while the domain points to an old nameserver.

- **Temporary Subdomains**:
  - Automatically generate temporary subdomains for previews, expiring after a set time (default: 3 hours).
  - Configurable expiration time to control the preview duration.

- **Cloudflare Integration**:
  - Automatically create subdomains on Cloudflare and remove them when the preview expires.

- **Efficient Storage with Lua Shared Dictionary**:
  - Use Lua's shared memory for managing subdomain-to-IP mappings efficiently, avoiding the need for external databases.

- **Fast and Scalable**:
  - Built on OpenResty (Nginx + Lua), offering high performance and scalability.

- **Dockerized Deployment**:
  - Fully containerized setup for easy deployment using Docker.
  - Exposes the service on port 3019 for easy integration.

---

## 🛠 **Technical Details**

1. **Nginx + Lua**:
   - Nginx handles HTTP requests, while Lua scripts dynamically generate and manage subdomains.
   - Shared memory (`lua_shared_dict`) stores temporary data like subdomain mappings.

2. **HTML Form Interface**:
   - A simple, responsive web form (`index.html`) allows users to input the domain and IP for preview creation.
   - The form integrates seamlessly with Lua to handle requests and set expiration timers.

3. **Cloudflare API Integration**:
   - Automates DNS record creation and deletion for temporary subdomains.
   - Ensures a smooth process for previewing sites under custom subdomains.

---

## 📦 **How to Use**

1. **Deploy with Docker**:
   - Build and run the Docker image provided in the repository:
     ```bash
     docker build -t previewsites .
     docker run -p 3019:3019 previewsites
     ```

2. **Access the Web Interface**:
   - Open your browser and navigate to `http://localhost:3019`.
   - Use the form to input the domain name and server IP.

3. **Temporary Subdomains**:
   - A subdomain like `yourdomain.previewsite.dev` will be created and automatically point to the new IP.
   - The subdomain expires after 3 hours (default) unless configured otherwise.

---

## 💡 **Use Cases**

- **Web Hosting Providers**:
  - Offer white-label previews to clients during server migrations or new deployments.
- **Developers**:
  - Test and debug sites on a new server without changing DNS records.
- **Site Migrations**:
  - Preview websites during migration to ensure functionality before updating the live DNS.

---

## 📖 **Contributing**

We welcome contributions to improve **previewsites.dev**! Feel free to submit a pull request or open an issue with your suggestions.

---

## 📜 **License**

This project is licensed under the MIT License. See the `LICENSE` file for details.
