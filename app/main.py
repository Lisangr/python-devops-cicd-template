import logging
from flask import Flask, jsonify, request

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
users = [
    {"id": 1, "name": "Alice"},
    {"id": 2, "name": "Bob"}
]


@app.route('/', methods=['GET'])
def index():
    return jsonify({"message": "Hello, World!"})


@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"}), 200


@app.route('/api/users', methods=['GET'])
def get_users():
    return jsonify({"users": users})


@app.route('/api/users', methods=['POST'])
def create_user():
    data = request.get_json()
    if not data or 'name' not in data:
        logger.error("Ошибка валидации: пропущено поле name")
        return jsonify({"error": "Missing name field"}), 400
    new_user = {"id": len(users) + 1, "name": data['name']}
    users.append(new_user)
    logger.info(f"Создан пользователь: {new_user['name']}")
    return jsonify(new_user), 201


@app.route('/api/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    user = next((u for u in users if u['id'] == user_id), None)
    if user:
        return jsonify(user)
    return jsonify({"error": "User not found"}), 404


@app.route('/api/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    global users
    user_index = next(
        (i for i, u in enumerate(users) if u['id'] == user_id),
        None
    )
    if user_index is not None:
        deleted_user = users.pop(user_index)
        logger.info(f"Удален пользователь: {deleted_user['name']}")
        return jsonify(
            {"message": "User deleted successfully", "user": deleted_user}
        ), 200
    return jsonify({"error": "User not found"}), 404


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)