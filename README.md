<h1 align="center">🏫 Smart Campus Forum</h1>

<p align="center">
  <b>An AI-powered platform transforming campus life through intelligent automation and unified services</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Frontend-Flutter-blue?style=for-the-badge&logo=flutter">
  <img src="https://img.shields.io/badge/Backend-FastAPI-black?style=for-the-badge&logo=fastapi">
  <img src="https://img.shields.io/badge/Database-Supabase-green?style=for-the-badge&logo=supabase">
  <img src="https://img.shields.io/badge/AI-Llama%203-orange?style=for-the-badge">
  <img src="https://img.shields.io/badge/Status-Active-success?style=for-the-badge">
</p>

---

## 🌟 Overview

**Smart Campus Forum** is a unified digital ecosystem designed to simplify and enhance campus life.

It brings together multiple essential campus services into a **single intelligent platform**, eliminating fragmented systems and improving communication, safety, and accessibility.

> 💡 From asking questions to reporting issues — everything happens in one place.

---

## 🚀 Core Features

### 🤖 AI Chatbot
- Instant, context-aware responses  
- Retrieval-Augmented Generation (RAG) based system  
- Smart navigation with deep linking  

---

### 📅 Event Management
- View and explore campus events  
- Easy participation access  
- Centralized event information  

---

### 🛡️ Safety & Harassment Reporting
- Secure and confidential reporting  
- Admin-controlled access  
- Promotes a safer campus environment  

---

### 🔍 Lost & Found System
- Report lost or found items  
- Image-based tracking  
- Status updates for recovery  

---

### 👥 Community Interaction
- Post and share updates  
- Engage in discussions  
- Build a connected campus community  

---

## 🧠 System Architecture

```mermaid
flowchart TD
A[Flutter App] --> B[FastAPI Backend]
B --> C[Supabase Database]
B --> D[AI Models (Llama)]
D --> B
C --> B
B --> A
