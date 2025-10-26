# Found from http://www.railstips.org/blog/archives/2006/11/18/class-and-instance-variables-in-ruby/
module ClassLevelInheritableAttributes
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def inheritable_attributes(*args)
      @inheritable_attributes ||= [:inheritable_attributes]
      @inheritable_attributes += args
      args.each do |arg|
        class_eval %(
          class << self; attr_accessor :#{arg} end
        )
      end
      @inheritable_attributes
    end

    def inherited(subclass)
      @inheritable_attributes.each do |inheritable_attribute|
        instance_var = "@#{inheritable_attribute}"
        subclass.instance_variable_set(instance_var, instance_variable_get(instance_var))
      end
    end
  end
end

module Darwinning
  class Organism
    include ClassLevelInheritableAttributes
    inheritable_attributes :genes, :name, :binary_coupled_genes
    attr_accessor :genotypes, :fitness, :name, :genes

    class << self
      attr_accessor :organism_traits
    end

    @genes = []  # Gene instances
    @binary_coupled_genes = {}
    @name = ""

    def initialize(genotypes = {})
      if genotypes == {}
        # fill genotypes with expressed Genes
        @genotypes = {}
        genes.each do |g|
          # make genotypes a hash with gene objects as keys
          @genotypes[g] = g.express
        end
      else
        @genotypes = genotypes
      end

      set_coupled_genes

      @fitness = nil
    end

    def set_coupled_genes
      self.class.binary_coupled_genes.each do |governing_gene_name, potential_consequences|
        governing_gene = genes.find { |gene| gene.name == governing_gene_name }
        governing_gene_value = @genotypes[governing_gene]

        real_consequences = potential_consequences[governing_gene_value] || {}
        real_consequences.each do |affected_gene_name, affected_gene_value|
          affected_gene = genes.find { |gene| gene.name == affected_gene_name }
          debugger if affected_gene.nil?
          @genotypes[affected_gene] = affected_gene_value

        end
      end

#      max_so_gene = self.class.genes.find { |g| g.name == 'max_safety_orders' }
#      step_gene = self.class.genes.find { |g| g.name == 'safety_order_step_percentage' }
#      debugger if @genotypes[step_gene] == 0 &&  @genotypes[max_so_gene] != 0
    end

    def name
      self.class.name
    end

    def genes
      self.class.genes
    end

    def gene_values
      genes.map { |g| @genotypes[g] }
    end
  end

end
