# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# TrieNode
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
class TrieNode
  include ActiveModel::Model
  attr_accessor :data, :next_letters, :seen, :heap_index

  def initialize
    @data, @next_letters, @seen, @heap_index = { frequency: 0 }, {}, false, -1
  end

  def visit
    @seen = !@seen
  end

  def add letter
    @next_letters[letter] ||= TrieNode.new
  end

  def next_letters_include? letter
    !(@next_letters[letter].nil?)
  end

  def record word
    @data[:frequency] += 1
    @data[:word] = word
    self
  end

  def to_s
    "#{@data[:word]}: #{@data[:frequency]}"
  end

end

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# TrieTree
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
class TrieTree
  include ActiveModel::Model

  def initialize
    @root = TrieNode.new
  end

  def add word
    # iterate through word characters and update trie where needed
    word.chars.inject(@root) do |current, letter|
      current.add(letter)
      current.next_letters[letter]
    end.record(word)
  end

  def longest_prefix_of word
    current = @root
    word.chars.each_with_object("") do |letter, prefix|
      while(current.next_letters_include?(letter))
        current = current.next_letters[letter]
        prefix << letter
      end
    end
  end

  def includes? word
    current = @root
    word.chars do |letter|
      if(current.next_letters_include?(letter))
        current = current.next_letters[letter]
      else
        return false
      end
    end
    current.data[:word] == word
  end

  # def wildcard_search_for(node=@root, expression)
  #   to_s() if expression == '*'
  #   node.visit
  #   expression.chars.each do |letter|
  #     while(current.next_letters_include?(letter))
  # end
  #
  # def traverse_from(node=@root)
  # end

  def to_s(node=@root)
    node.visit
    puts node if (node.data[:frequency] > 0)
    unless (node.next_letters.empty?)
      node.next_letters.each do |neighbor, value|
        to_s(value) unless value.seen == node.seen
      end
    end
  end
end


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# HeapNode
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
class HeapNode
  include ActiveModel::Model
  attr_accessor :trie_node, :frequency, :word

  def initialize trie_node, heap_index
    @trie_node = trie_node
    @trie_node.heap_index = heap_index
    @frequency = trie_node.data[:frequency]
    @word = trie_node.data[:word]
  end

  def data
    { @word => @frequency }
  end

end

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Heap
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
class Heap
  include ActiveModel::Model
  attr_accessor :nodes

  def initialize(many_keywords)
    @capacity = many_keywords
    @nodes = []
  end
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  # Add
  # 1: trie_node exists in tree, update tree
  # 2: heap is full, replace root of heap if word frequency is greater than min of heap
  # 3: heap is not full and word is not in heap
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  def add trie_node
    case
    when trie_node.heap_index != -1
      @nodes[trie_node.heap_index].frequency += 1
      heapify_down_from(trie_node.heap_index)
    when @nodes.length == @capacity
      replace_root_with(trie_node) if trie_node.data[:frequency] > @nodes[0].frequency
    else
      @nodes.push(HeapNode.new(trie_node, @nodes.length))
      heapify_up_from((@nodes.length-1))
    end
  end

  def replace_root_with trie_node
    @nodes[0] = HeapNode.new(trie_node, 0)
    heapify_down_from(0)
  end

  def swap index1, index2
    @nodes[index1], @nodes[index2] = @nodes[index2], @nodes[index1]
    @nodes[index1].trie_node.heap_index = index1
    @nodes[index2].trie_node.heap_index = index2
  end

  # make sure parents have lower frequency than children
  def heapify_down_from index
    current, lchild, rchild = @nodes[index], @nodes[2*index+1], @nodes[2*index+2]
    if(lchild && (current.frequency > lchild.frequency))
      swap index, (2*index+1)
      heapify_down_from(2*index+1)
    end
    if(rchild && (current.frequency > rchild.frequency))
      swap index, (2*index+2)
      heapify_down_from(2*index+2)
    end
  end

  # make sure children don't have lower frequency than parents
  def heapify_up_from index
    parent_index = index.odd? ? index/2 : index/2-1
    current, parent = @nodes[index], @nodes[parent_index]
    if(current.frequency < parent.frequency)
      swap index, parent_index
      heapify_up_from(index/2+1)
    end
  end

  def sort
    sorted, nodes = [], @nodes.clone
    nodes.length.downto(1) do |i|
      swap(0, (i-1))
      sorted.unshift @nodes.pop.data
      heapify_down_from 0
    end
    @nodes = nodes
    sorted
  end

  def to_s
    @nodes.each { |node| ap node.data }
  end
end

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# TrieHeap
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
class TrieHeap
  include ActiveModel::Model
  attr_accessor :trie_tree, :heap

  def initialize(many_keywords=15)
    @trie_tree = TrieTree.new
    @heap = Heap.new(many_keywords)
  end

  def add word
    @heap.add(@trie_tree.add(word))
  end

  def sort
    @heap.sort
  end
end
