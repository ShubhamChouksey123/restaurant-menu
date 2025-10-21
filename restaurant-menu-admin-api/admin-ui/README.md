# Restaurant Menu Admin UI

React-based admin interface for managing restaurant menu via Spring Boot API.

## 🚀 Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Start Development Server

```bash
npm run dev
```

The app will be available at `http://localhost:3000`

### 3. Login

Default credentials:
- **Username:** admin
- **Password:** admin123

## 📦 Build for Production

```bash
npm run build
```

The production build will be in the `dist` folder.

## 🔧 Configuration

Create `.env.local` file to override API URL:

```
VITE_API_URL=http://your-backend-url:8080
```

## 📱 Features

- ✅ JWT Authentication with login/logout
- ✅ Dashboard with menu statistics
- ✅ Category tabs navigation
- ✅ Dish management (toggle availability, update price, delete)
- ✅ Real-time Git commit notifications
- ✅ Responsive design
- ✅ Error handling

## 🎨 Tech Stack

- React 18
- Vite
- Axios
- CSS3

## 📝 Usage

### Toggle Dish Availability

Click "Toggle" button on any dish to mark it as available/unavailable. This will:
1. Update the database
2. Commit to Git with message: `"Mark dish available/unavailable: [Dish Name]"`
3. Push to GitHub
4. Trigger deployment

### Update Dish Price

Click "Price" button, enter new price. This will:
1. Update the price
2. Commit to Git with message: `"Update [Dish Name] price: ₹X → ₹Y"`
3. Push to GitHub
4. Trigger deployment

### Delete Dish

Click "Delete" button (confirmation required). This will:
1. Remove the dish
2. Commit to Git with message: `"Delete dish: [Dish Name]"`
3. Push to GitHub
4. Trigger deployment

## 🔗 API Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/auth/login` | POST | User authentication |
| `/api/categories` | GET | Get all categories |
| `/api/categories/{id}/dishes` | GET | Get dishes by category |
| `/api/categories/{categoryId}/dishes/{dishId}/availability` | PATCH | Toggle availability |
| `/api/categories/{categoryId}/dishes/{dishId}/price` | PATCH | Update price |
| `/api/categories/{categoryId}/dishes/{dishId}` | DELETE | Delete dish |

## 🛠️ Development

The project uses Vite proxy to avoid CORS issues during development:

```js
// vite.config.js
server: {
  port: 3000,
  proxy: {
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true,
    }
  }
}
```

## 📄 License

MIT License
