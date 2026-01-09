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

- **Efficient Storage with Lua Shared Dictionary**:
  - Use Lua's shared memory for managing subdomain-to-IP mappings efficiently, avoiding the need for external databases.

- **Fast and Scalable**:
  - Built on OpenResty (Nginx + Lua), offering high performance and scalability.

- **Dockerized Deployment**:
  - Fully containerized setup for easy deployment using Docker.
  - Exposes the service on port 80 for easy integration.

- **Automatic WEBP Image Optimization**:
  - On-the-fly conversion of JPG, JPEG, and PNG images to WEBP format for modern browsers.
  - Automatic browser detection and fallback to original format for older browsers.
  - Persistent caching system to avoid repeated conversions and improve performance.

---

## 🛠 **Technical Details**

1. **Nginx + Lua**:
   - Nginx handles HTTP requests, while Lua scripts dynamically generate and manage subdomains.
   - Shared memory (`lua_shared_dict`) stores temporary data like subdomain mappings.

2. **HTML Form Interface**:
   - A simple, responsive web form (`index.html`) allows users to input the domain and IP for preview creation.
   - The form integrates seamlessly with Lua to handle requests and set expiration timers.

3. **Image Optimization with WEBP**:
   - Automatic on-the-fly conversion of images (JPG, JPEG, PNG) to WEBP format using Lua scripts.
   - Uses libvips (preferred) or ImageMagick (fallback) for efficient image processing.
   - Browser support detection via `Accept` header - modern browsers receive WEBP, older browsers receive original format.
   - Persistent disk caching to avoid repeated conversions and ensure fast subsequent requests.
   - Quality set to 85% for optimal balance between file size and image quality.

---

## 📦 **How to Use**

1. **Deploy with Docker**:
   - Build and run the Docker image provided in the repository:
     ```bash
     docker build -t previewsites .
     docker run -p 80:80 previewsites
     ```

2. **Access the Web Interface**:
   - Open your browser and navigate to `http://localhost`.
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

## 🖼️ **Image Optimization**

**previewsites.dev** includes automatic WEBP image optimization for improved performance:

- **Supported Formats**: JPG, JPEG, PNG are automatically converted to WEBP
- **Browser Detection**: Automatically detects browser WEBP support via `Accept` header
- **Smart Caching**: Converted images are cached on disk to avoid repeated conversions
- **Fallback Support**: Older browsers automatically receive the original image format
- **Performance**: Uses libvips (preferred) or ImageMagick (fallback) for fast, efficient conversion

For detailed information about the WEBP optimization feature, see [WEBP_OPTIMIZATION.md](./WEBP_OPTIMIZATION.md).

---

## 📖 **Contributing**

We welcome contributions to improve **previewsites.dev**! Feel free to submit a pull request or open an issue with your suggestions.

---

## 📜 **License**

This project is licensed under the MIT License. See the `LICENSE` file for details.
