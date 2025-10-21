import { useState, useEffect } from 'react';
import { categoryAPI, dishAPI } from '../services/api';

function Dashboard({ onLogout }) {
  const [categories, setCategories] = useState([]);
  const [selectedCategory, setSelectedCategory] = useState(null);
  const [dishes, setDishes] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [user, setUser] = useState(null);

  useEffect(() => {
    const userStr = localStorage.getItem('user');
    if (userStr) {
      setUser(JSON.parse(userStr));
    }
    loadCategories();
  }, []);

  const loadCategories = async () => {
    try {
      const response = await categoryAPI.getAll();
      setCategories(response.data);
      if (response.data.length > 0) {
        selectCategory(response.data[0]);
      }
    } catch (error) {
      console.error('Error loading categories:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const selectCategory = async (category) => {
    setSelectedCategory(category);
    setIsLoading(true);
    try {
      const response = await dishAPI.getByCategory(category.id);
      setDishes(response.data);
    } catch (error) {
      console.error('Error loading dishes:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleToggleAvailability = async (dish) => {
    try {
      await dishAPI.toggleAvailability(selectedCategory.id, dish.id);
      // Reload dishes
      selectCategory(selectedCategory);
      alert(`Dish ${dish.available ? 'marked unavailable' : 'marked available'} successfully! Changes committed to GitHub.`);
    } catch (error) {
      console.error('Error toggling availability:', error);
      alert('Failed to toggle availability');
    }
  };

  const handleUpdatePrice = async (dish) => {
    const newPrice = prompt(`Enter new price for ${dish.name}:`, dish.price);
    if (newPrice === null) return;

    const price = parseInt(newPrice);
    if (isNaN(price) || price < 0) {
      alert('Please enter a valid price');
      return;
    }

    try {
      await dishAPI.updatePrice(selectedCategory.id, dish.id, price);
      selectCategory(selectedCategory);
      alert(`Price updated from ₹${dish.price} to ₹${price}! Changes committed to GitHub.`);
    } catch (error) {
      console.error('Error updating price:', error);
      alert('Failed to update price');
    }
  };

  const handleDeleteDish = async (dish) => {
    if (!confirm(`Are you sure you want to delete ${dish.name}?`)) {
      return;
    }

    try {
      await dishAPI.delete(selectedCategory.id, dish.id);
      selectCategory(selectedCategory);
      alert(`${dish.name} deleted successfully! Changes committed to GitHub.`);
    } catch (error) {
      console.error('Error deleting dish:', error);
      alert('Failed to delete dish');
    }
  };

  const totalDishes = categories.reduce((sum, cat) => sum + cat.dishes.length, 0);
  const availableDishes = categories.reduce(
    (sum, cat) => sum + cat.dishes.filter(d => d.available).length,
    0
  );

  return (
    <>
      <header className="header">
        <div className="container">
          <nav className="nav">
            <div>
              <h1>Restaurant Menu Admin</h1>
              <p>Welcome, {user?.username || 'Admin'}!</p>
            </div>
            <button onClick={onLogout} className="logout-btn">
              Logout
            </button>
          </nav>
        </div>
      </header>

      <div className="container dashboard">
        <div className="stats">
          <div className="stat-card">
            <h3>Total Categories</h3>
            <div className="number">{categories.length}</div>
          </div>
          <div className="stat-card">
            <h3>Total Dishes</h3>
            <div className="number">{totalDishes}</div>
          </div>
          <div className="stat-card">
            <h3>Available Dishes</h3>
            <div className="number">{availableDishes}</div>
          </div>
          <div className="stat-card">
            <h3>Unavailable</h3>
            <div className="number">{totalDishes - availableDishes}</div>
          </div>
        </div>

        <div className="tabs">
          {categories.map((category) => (
            <button
              key={category.id}
              className={`tab ${selectedCategory?.id === category.id ? 'active' : ''}`}
              onClick={() => selectCategory(category)}
            >
              {category.name} ({category.dishes.length})
            </button>
          ))}
        </div>

        <div className="table-container">
          <div className="table-header">
            <h2>{selectedCategory?.name || 'Select a category'}</h2>
          </div>

          {isLoading ? (
            <div className="loading">Loading...</div>
          ) : dishes.length === 0 ? (
            <div className="empty-state">
              <h3>No dishes in this category</h3>
              <p>Start by adding dishes to this category</p>
            </div>
          ) : (
            <table>
              <thead>
                <tr>
                  <th>Image</th>
                  <th>Name</th>
                  <th>Price</th>
                  <th>Status</th>
                  <th>Veg</th>
                  <th>Spicy</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {dishes.map((dish) => (
                  <tr key={dish.id}>
                    <td>
                      <img
                        src={`/${dish.image}`}
                        alt={dish.name}
                        className="dish-image"
                        onError={(e) => {
                          e.target.src = 'https://via.placeholder.com/50';
                        }}
                      />
                    </td>
                    <td>
                      <strong>{dish.name}</strong>
                      {dish.description && (
                        <div style={{ fontSize: '12px', color: '#666', marginTop: '4px' }}>
                          {dish.description}
                        </div>
                      )}
                    </td>
                    <td>
                      <strong>₹{dish.price}</strong>
                    </td>
                    <td>
                      <span className={`badge ${dish.available ? 'badge-success' : 'badge-danger'}`}>
                        {dish.available ? 'Available' : 'Unavailable'}
                      </span>
                    </td>
                    <td>{dish.is_vegetarian ? '✅' : '❌'}</td>
                    <td>{dish.is_spicy ? '🌶️' : '-'}</td>
                    <td>
                      <div className="actions">
                        <button
                          className="btn-icon btn-toggle"
                          onClick={() => handleToggleAvailability(dish)}
                          title="Toggle Availability"
                        >
                          Toggle
                        </button>
                        <button
                          className="btn-icon btn-edit"
                          onClick={() => handleUpdatePrice(dish)}
                          title="Update Price"
                        >
                          Price
                        </button>
                        <button
                          className="btn-icon btn-delete"
                          onClick={() => handleDeleteDish(dish)}
                          title="Delete Dish"
                        >
                          Delete
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>

        <div style={{ marginTop: '30px', padding: '20px', background: 'white', borderRadius: '8px' }}>
          <h3 style={{ marginBottom: '10px' }}>Git Integration Status</h3>
          <p style={{ color: '#666', marginBottom: '10px' }}>
            ✅ All changes are automatically committed and pushed to GitHub
          </p>
          <p style={{ color: '#666', fontSize: '14px' }}>
            Every menu update creates a Git commit with a descriptive message and triggers GitHub Actions deployment.
            Changes will be live on GitHub Pages in 1-2 minutes after saving.
          </p>
        </div>
      </div>
    </>
  );
}

export default Dashboard;
