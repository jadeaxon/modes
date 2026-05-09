#Requires AutoHotkey v2.0

class List {
    __New(initialArray := []) {
        this.data := initialArray
    }


    append(item) {
        this.data.Push(item)
    }

    extend(iterable) {
        ; Supports both standard AHK Arrays and custom List objects
        target := (iterable is List) ? iterable.data : iterable
        for item in target {
            this.data.Push(item)
        }
    }

    insert(index, item) {
        this.data.InsertAt(index + 1, item)
    }

    remove(item) {
        for i, val in this.data {
            if (val == item) {
                this.data.RemoveAt(i)
                return
            }
        }
        throw ValueError("list.remove(x): x not in list", -1)
    }

    pop(index := -1) {
        if (this.data.Length == 0)
            throw IndexError("pop from empty list", -1)
        
        ; Handle negative indexing: -1 is last, -2 is second to last.
        realIndex := this._translate_index(index)
        
        if (realIndex < 1 || realIndex > this.data.Length)
            throw IndexError("pop index out of range", -1)

        val := this.data[realIndex]
        this.data.RemoveAt(realIndex)
        return val
    }

    clear() {
        this.data := []
    }

    index(item, start := 0) {
        for i, val in this.data {
            if (i > start && val == item)
                return i - 1
        }
        throw ValueError("'" . item . "' is not in list", -1)
    }

    count(item) {
        num := 0
        for val in this.data {
            if (val == item)
                num++
        }
        return num
    }

    reverse() {
        newArray := []
        Loop this.data.Length {
            newArray.Push(this.data[this.data.Length - A_Index + 1])
        }
        this.data := newArray
    }

    copy() {
        return List(this.data.Clone())
    }

    length => this.data.Length

    _translate_index(i) {
        return (i < 0) ? (this.data.Length + i + 1) : (i + 1)
    }

    __Item[index] {
        get => this.data[this._translate_index(index)]
        set => this.data[this._translate_index(index)] := value
    }

    ; Enables 'for item in my_list'
    __Enum(params) => this.data.__Enum(params)
} ; List class

