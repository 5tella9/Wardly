import React, { useState } from 'react'

export default function Profile({user, setUser}){
  const [edit, setEdit] = useState(false)
  const [form, setForm] = useState({...user})

  function save(){
    // update stored users
    const users = JSON.parse(localStorage.getItem('wardly_users')||'[]')
    const idx = users.findIndex(u=>u.email===user.email)
    if(idx>=0) users[idx] = form
    localStorage.setItem('wardly_users', JSON.stringify(users))
    setUser(form)
    setEdit(false)
  }

  function del(){
    if(!confirm('Hapus account?')) return
    let users = JSON.parse(localStorage.getItem('wardly_users')||'[]')
    users = users.filter(u=>u.email!==user.email)
    localStorage.setItem('wardly_users', JSON.stringify(users))
    setUser(null)
  }

  return (
    <div className="profile-card">
      <h3>Profile</h3>
      {edit? (
        <div>
          <input value={form.username} onChange={e=>setForm({...form,username:e.target.value})} />
          <input placeholder="avatar dataUrl (paste)" value={form.avatar||''} onChange={e=>setForm({...form,avatar:e.target.value})} />
          <button onClick={save}>Save</button>
        </div>
      ) : (
        <div>
          <p>Username: {user.username}</p>
          <p>Email: {user.email}</p>
          <button onClick={()=>setEdit(true)}>Edit Profile</button>
        </div>
      )}
      <div style={{marginTop:10}}>
        <h4>Dashboard</h4>
        <p>Items in wardrobe: {JSON.parse(localStorage.getItem('wardly_items')||'[]').length}</p>
        <button onClick={()=>{localStorage.removeItem('wardly_items'); alert('Items cleared')}}>Clear items</button>
      </div>
      <div style={{marginTop:10}}>
        <button onClick={()=>setUser(null)}>Logout</button>
        <button onClick={del} style={{color:'red'}}>Delete Account</button>
      </div>
    </div>
  )
}