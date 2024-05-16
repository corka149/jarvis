package store

import (
	"time"
)

type List struct {
	Id       int
	Deleted  bool
	UpdateOn time.Time

	Reason string
	On     time.Time
	Items  []Item
}

type Item struct {
	Name   string
	Amount int
}

type Store struct {
	lists  map[int]*List
	lastId int
}

type Page struct {
	PageNumber  int
	PageSize    int
	TotalAmount int

	Content []*List
}

func NewStore() *Store {
	return &Store{
		lists:  make(map[int]*List),
		lastId: 1,
	}
}

func (s *Store) SaveList(list List) *List {
	if list.Id == 0 {
		list.Id = s.lastId
		s.lastId = s.lastId + 1
	}

	s.lists[list.Id] = &list

	return &list
}

func (s *Store) Delete(id int) {
	delete(s.lists, id)
}

func (s *Store) FetchList(id int) *List {
	return s.lists[id]
}

func (s *Store) FetchLists(pageNumber int, pageSize int) Page {
	content := make([]*List, 0, len(s.lists))

	for _, list := range s.lists {
		content = append(content, list)
	}

	return Page{
		PageNumber:  pageNumber,
		PageSize:    pageSize,
		TotalAmount: len(s.lists),
		Content:     content,
	}
}
