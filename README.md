# Expense Tracker

Expense Tracker is a web application that helps individuals manage their finances by tracking personal expenses, visualizing spending by category, and comparing monthly trends. Built with Ruby on Rails, it provides a modern, user-friendly interface for adding, editing, and analyzing expenses.

---

## Screenshots

![Screenshot 2025-06-26 at 9 01 10](https://github.com/user-attachments/assets/dea0c7cc-3cdd-418c-b3cb-db5b2261b01d)
![Screenshot 2025-06-26 at 9 01 25](https://github.com/user-attachments/assets/32cbaa20-6cd5-44ec-a56f-65e0e59e79e4)

---

## Features

- **Dashboard:**  
  View a summary of your expenses for the current month, including total spent and a breakdown by category.

- **Expense Tracking:**  
  Add, edit, and delete expenses with predefined categories (e.g., Food & Dining, Transportation, Shopping, etc.).

- **Monthly Overview:**  
  Visualize your total expenses for each month of the current year with a bar chart.

- **Category Visualization:**  
  See a bar graph of your spending by category for the current month.

- **Bulk Actions:**  
  Select multiple expenses to edit or delete in bulk, with a modern, scrollable list and fixed action buttons.

- **Responsive UI:**  
  Clean, modern design with responsive layout and custom scrollbars for a great experience on any device.

---

## Tech Stack

- **Ruby on Rails 8.0.2:** Web application framework
- **Ruby 3.2.2:** Programming language
- **HTML/CSS:** Front-end structure and styling
- **JavaScript:** Interactive UI components
- **SQLite3/PostgreSQL:** Database (default: SQLite for development)
- **Chart.js:** For data visualization (if used; otherwise, mention your charting library)

---

## Setup Instructions

### 1. Prerequisites

- **Ruby** (version 3.2.2 recommended)
- **Rails** (version 8.0.2)
- **Bundler** (for managing Ruby gems)
- **Git** (for version control)
- **Node.js & Yarn** (if using JavaScript assets that require them)

### 2. Install Ruby & Rails

If you don’t have Ruby or Rails installed, use a version manager like [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/):

```sh
# Install Ruby
rbenv install 3.2.2
rbenv global 3.2.2

# Install Rails
gem install rails -v 8.0.2
```

### 3. Clone the Repository

```sh
git clone <link>
cd expense-tracker-rails
```

### 4. Install Dependencies

```sh
bundle install
```

### 5. Set Up the Database

```sh
bin/rails db:setup
```
This will create, migrate, and seed the database.

### 6. Start the Rails Server

```sh
bin/rails server
```
Visit [http://localhost:3000](http://localhost:3000) in your browser.

---

## Contributing

We welcome contributions! To contribute:

1. Fork the repository.
2. Create a new branch: `git checkout -b feature-name`
3. Make your changes and commit: `git commit -am 'Add feature'`
4. Push to your branch: `git push origin feature-name`
5. Open a pull request.

---

## License

This project is open-source and available under the [MIT License](LICENSE).

---
