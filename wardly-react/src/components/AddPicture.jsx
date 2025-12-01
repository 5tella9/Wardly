import React, { useRef } from 'react'

const STORAGE_KEY = 'wardly_items'

export default function AddPicture({onAdd}){
  const fileRef = useRef()

  function onFile(e){
    const f = e.target.files[0]
    if(!f) return
    const reader = new FileReader()
    reader.onload = ()=>{
      const dataUrl = reader.result
      const items = JSON.parse(localStorage.getItem(STORAGE_KEY)||'[]')
      const type = prompt('Tulis type barang: Pants / Skirts / Top / Dresses (case sensitive)') || 'Top'
      items.unshift({id:Date.now(), dataUrl, type, fav:false})
      localStorage.setItem(STORAGE_KEY, JSON.stringify(items))
      alert('Item ditambahkan!')
      if(onAdd) onAdd()
    }
    reader.readAsDataURL(f)
  }

  return (
    <div className="add-card">
      <h3>Add Picture</h3>
      <input ref={fileRef} type="file" accept="image/*" onChange={onFile} />
      <p className="muted">Pilih dari gallery / foto. Pada browser mobile, file picker akan mengizinkan memilih foto.</p>
    </div>
  )
}