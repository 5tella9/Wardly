import React, { useState, useEffect } from 'react'
import Homepage from './components/Homepage'
import AddPicture from './components/AddPicture'
import Profile from './components/Profile'

function App(){
  const [route, setRoute] = useState('home')
  const [user, setUser] = useState(JSON.parse(localStorage.getItem('wardly_user')) || null)

  useEffect(()=>{
    localStorage.setItem('wardly_user', JSON.stringify(user))
  },[user])

  return (
    <div className="app-bg">
      {!user ? (
        <Auth onLogin={u=>setUser(u)} />
      ) : (
        <div className="app-shell">
          <div className="topbar"> <h1>WARDLY</h1> </div>

          <main className="content">
            {route === 'home' && <Homepage />}
            {route === 'add' && <AddPicture onAdd={()=>setRoute('home')}/>}
            {route === 'profile' && <Profile user={user} setUser={setUser} />}
          </main>

          <nav className="bottom-nav">
            <button onClick={()=>setRoute('home')}>Homepage</button>
            <button onClick={()=>setRoute('add')}>Add Pictures</button>
            <button onClick={()=>setRoute('profile')}>Profile</button>
          </nav>
        </div>
      )}
    </div>
  )
}

export default App

// Simple Auth component (client-only, for demo)
function Auth({onLogin}){
  const [isLogin, setIsLogin] = useState(true)
  const [form, setForm] = useState({username:'',email:'',password:''})

  function submit(e){
    e.preventDefault()
    if(isLogin){
      // try get from localStorage users
      const users = JSON.parse(localStorage.getItem('wardly_users')||'[]')
      const u = users.find(x=>x.email===form.email && x.password===form.password)
      if(u) onLogin(u)
      else alert('Login failed — email/password salah (demo)')
    } else {
      const users = JSON.parse(localStorage.getItem('wardly_users')||'[]')
      if(users.find(x=>x.email===form.email)) return alert('Email sudah dipakai')
      const newUser = {username: form.username || form.email.split('@')[0], email: form.email, password: form.password, avatar: null}
      users.push(newUser)
      localStorage.setItem('wardly_users', JSON.stringify(users))
      onLogin(newUser)
    }
  }

  return (
    <div className="auth-card">
      <h2>{isLogin? 'Login' : 'Create Account'}</h2>
      <form onSubmit={submit}>
        {!isLogin && (
          <input placeholder="username" value={form.username} onChange={e=>setForm({...form,username:e.target.value})} required />
        )}
        <input placeholder="email" value={form.email} onChange={e=>setForm({...form,email:e.target.value})} required />
        <input placeholder="password" type="password" value={form.password} onChange={e=>setForm({...form,password:e.target.value})} required />
        <button type="submit">{isLogin? 'Login' : 'Create'}</button>
      </form>
      <p onClick={()=>setIsLogin(!isLogin)} style={{cursor:'pointer'}}>{isLogin? 'Buat account baru' : 'Sudah punya account? Login'}</p>
    </div>
  )
}