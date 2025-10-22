import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle 401 errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Auth API
export const authAPI = {
  login: (credentials) => api.post('/api/auth/login', credentials),
  validate: () => api.get('/api/auth/validate'),
};

// Menu API
export const menuAPI = {
  getMenu: () => api.get('/api/menu'),
};

// Category API
export const categoryAPI = {
  getAll: () => api.get('/api/categories'),
  getById: (id) => api.get(`/api/categories/${id}`),
  create: (category) => api.post('/api/categories', category),
  update: (id, category) => api.put(`/api/categories/${id}`, category),
  delete: (id) => api.delete(`/api/categories/${id}`),
};

// Dish API
export const dishAPI = {
  getByCategory: (categoryId) => api.get(`/api/categories/${categoryId}/dishes`),
  getById: (categoryId, dishId) => api.get(`/api/categories/${categoryId}/dishes/${dishId}`),
  create: (categoryId, dish) => api.post(`/api/categories/${categoryId}/dishes`, dish),
  update: (categoryId, dishId, dish) => api.put(`/api/categories/${categoryId}/dishes/${dishId}`, dish),
  delete: (categoryId, dishId) => api.delete(`/api/categories/${categoryId}/dishes/${dishId}`),
  toggleAvailability: (categoryId, dishId) => api.patch(`/api/categories/${categoryId}/dishes/${dishId}/availability`),
  updatePrice: (categoryId, dishId, price) => api.patch(`/api/categories/${categoryId}/dishes/${dishId}/price`, { price }),
};

export default api;
