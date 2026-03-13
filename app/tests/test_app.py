import pytest
from app.main import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_index(client):
    response = client.get('/')
    assert response.status_code == 200
    assert response.get_json() == {"message": "Hello, World!"}

def test_health(client):
    assert client.get('/health').status_code == 200

def test_get_users(client):
    response = client.get('/api/users')
    assert response.status_code == 200
    json_data = response.get_json()
    assert 'users' in json_data
    assert len(json_data['users']) >= 2

def test_create_user_success(client):
    response = client.post('/api/users', json={"name": "DevOps"})
    assert response.status_code == 201
    json_data = response.get_json()
    assert json_data['name'] == "DevOps"
    assert 'id' in json_data

def test_create_user_fail(client):
    response = client.post('/api/users', json={})
    assert response.status_code == 400
    assert response.get_json()['error'] == "Missing name field"

def test_get_user_not_found(client):
    response = client.get('/api/users/999')
    assert response.status_code == 404
    assert response.get_json()['error'] == "User not found"

def test_get_user_success(client):
    response = client.get('/api/users/1')
    assert response.status_code == 200
    json_data = response.get_json()
    assert json_data['id'] == 1
    assert json_data['name'] == "Alice"

def test_delete_user_success(client):
    # Сначала создаем пользователя для удаления
    create_response = client.post('/api/users', json={"name": "Test User"})
    user_id = create_response.get_json()['id']

    # Удаляем пользователя
    delete_response = client.delete(f'/api/users/{user_id}')
    assert delete_response.status_code == 200
    json_data = delete_response.get_json()
    assert json_data['message'] == "User deleted successfully"
    assert json_data['user']['name'] == "Test User"

    # Проверяем, что пользователь удален
    get_response = client.get(f'/api/users/{user_id}')
    assert get_response.status_code == 404

def test_delete_user_not_found(client):
    response = client.delete('/api/users/999')
    assert response.status_code == 404
    assert response.get_json()['error'] == "User not found"