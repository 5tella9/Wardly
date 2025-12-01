import React, { useState, useEffect } from 'react'

const STORAGE_KEY = 'wardly_items'

export default function Homepage(){
  const [items, setItems] = useState(JSON.parse(localStorage.getItem(STORAGE_KEY)||'[]'))
  const [filter, setFilter] = useState('All')

  useEffect(()=>{
    localStorage.setItem(STORAGE_KEY, JSON.stringify(items))
  },[items])

  function toggleFav(id){
    setItems(items.map(it => it.id===id ? {...it, fav: !it.fav} : it))
  }

  const displayed = items.filter(it => filter==='All' ? true : it.type===filter)

  return (
    <div>
      <div className="homepage-header">
        <h2>My Wardrobe</h2>
        <div className="filter-row">
          {['All','Pants','Skirts','Top','Dresses'].map(f=> (
            <button key={f} className={`chip ${filter===f? 'active':''}`} onClick={()=>setFilter(f)}>{f}</button>
          ))}
        </div>
      </div>

      <div className="grid">
        {displayed.length===0 && <p className="muted">No items yet — add some from Add Pictures</p>}
        {displayed.map(it => (
          <div key={it.id} className="card">
            <img src={it.dataUrl} alt="item" />
            <button className="fav" onClick={()=>toggleFav(it.id)}>{it.fav? '❤️' : '🤍'}</button>
            <div className="meta">{it.type}</div>
          </div>
        ))}
      </div>
    </div>
  )
}