module Darwinning
  module EvolutionTypes

    class Mutation
      attr_reader :mutation_rate

      def initialize(options = {})
        @mutation_rate = options.fetch(:mutation_rate, 0.0)
      end

      def evolve(members)
        mutate(members)
      end

      def pairwise?
        false
      end

      protected

      def mutate(members)
        members.map do |member|
          if rand < mutation_rate
            re_express_random_genotypes(member)
          else
            member
          end
        end
      end

      # Selects a random genotype from the organism and re-expresses its gene
      def re_express_random_genotypes(member)
        max_mutations_count = rand(member.genotypes.length / 3)

        max_mutations_count.times do
          random_index = rand(member.genotypes.length)
          gene = member.genes[random_index]

          if member.class.superclass == Darwinning::Organism
            old_value = member.genotypes[gene]
            while member.genotypes[gene] == old_value
              member.genotypes[gene] = gene.express
            end
          else
            member.send("#{gene.name}=", gene.express)
          end
        end

        member
      end
    end

  end
end
